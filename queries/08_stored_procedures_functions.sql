-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 08_stored_procedures_functions.sql
-- Category: Stored Procedures, Functions, Triggers, Transactions
-- PostgreSQL 14+ Compatible
-- ============================================================

-- ============================================================
-- SECTION 1: FUNCTIONS
-- ============================================================

-- Function 1: Calculate churn rate for a given contract type
CREATE OR REPLACE FUNCTION fn_get_churn_rate(p_contract VARCHAR)
RETURNS TABLE(total_customers BIGINT, churned BIGINT, churn_rate NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END)::BIGINT,
        ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
    FROM telecom_churn
    WHERE contract = p_contract;
END;
$$;

-- Usage: SELECT * FROM fn_get_churn_rate('Month-to-month');

-- Function 2: Get customer risk level
CREATE OR REPLACE FUNCTION fn_get_risk_level(p_churn_score INT)
RETURNS VARCHAR
LANGUAGE plpgsql AS $$
BEGIN
    RETURN CASE 
        WHEN p_churn_score >= 70 THEN 'High Risk'
        WHEN p_churn_score >= 40 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END;
END;
$$;

-- Usage: SELECT fn_get_risk_level(75);

-- Function 3: Calculate CLTV tier
CREATE OR REPLACE FUNCTION fn_get_cltv_tier(p_cltv INT)
RETURNS VARCHAR
LANGUAGE plpgsql AS $$
BEGIN
    RETURN CASE 
        WHEN p_cltv >= 5000 THEN 'Platinum'
        WHEN p_cltv >= 4000 THEN 'Gold'
        WHEN p_cltv >= 3000 THEN 'Silver'
        WHEN p_cltv >= 2000 THEN 'Bronze'
        ELSE 'Basic'
    END;
END;
$$;

-- Usage: SELECT fn_get_cltv_tier(4500);

-- Function 4: Calculate revenue at risk for a contract
CREATE OR REPLACE FUNCTION fn_revenue_at_risk(p_contract VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
    v_revenue NUMERIC;
BEGIN
    SELECT COALESCE(SUM(monthly_charges), 0) INTO v_revenue
    FROM telecom_churn
    WHERE contract = p_contract AND churn_label = 'Yes';
    RETURN v_revenue;
END;
$$;

-- Usage: SELECT fn_revenue_at_risk('Month-to-month');

-- Function 5: Get top N customers by charges
CREATE OR REPLACE FUNCTION fn_top_customers(p_limit INT DEFAULT 10)
RETURNS TABLE(
    customer_id VARCHAR,
    contract VARCHAR,
    monthly_charges DECIMAL,
    total_charges DECIMAL,
    churn_label VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.customer_id, tc.contract, tc.monthly_charges, 
        tc.total_charges, tc.churn_label
    FROM telecom_churn tc
    ORDER BY tc.monthly_charges DESC
    LIMIT p_limit;
END;
$$;

-- Usage: SELECT * FROM fn_top_customers(5);

-- ============================================================
-- SECTION 2: STORED PROCEDURES
-- ============================================================

-- Procedure 1: Update churn scores based on rules
CREATE OR REPLACE PROCEDURE sp_update_churn_scores()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE telecom_churn
    SET churn_score = CASE 
        WHEN contract = 'Month-to-month' AND tenure_months <= 12 THEN 85
        WHEN contract = 'Month-to-month' AND tenure_months <= 24 THEN 70
        WHEN contract = 'One year' THEN 40
        WHEN contract = 'Two year' THEN 20
        ELSE churn_score
    END;
    
    RAISE NOTICE 'Churn scores updated successfully';
END;
$$;

-- Usage: CALL sp_update_churn_scores();

-- Procedure 2: Archive churned customers
CREATE OR REPLACE PROCEDURE sp_archive_churned()
LANGUAGE plpgsql AS $$
BEGIN
    -- Create archive table if not exists
    CREATE TABLE IF NOT EXISTS telecom_churn_archive AS
    SELECT * FROM telecom_churn WHERE 1=0;
    
    -- Insert churned customers
    INSERT INTO telecom_churn_archive
    SELECT * FROM telecom_churn 
    WHERE churn_label = 'Yes'
    AND customer_id NOT IN (SELECT customer_id FROM telecom_churn_archive);
    
    RAISE NOTICE 'Archived % churned customers', 
        (SELECT COUNT(*) FROM telecom_churn WHERE churn_label = 'Yes');
END;
$$;

-- Usage: CALL sp_archive_churned();

-- Procedure 3: Generate segment report
CREATE OR REPLACE PROCEDURE sp_segment_report(p_segment VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RAISE NOTICE '=== Segment Report: % ===', p_segment;
    RAISE NOTICE 'Total customers: %', (
        SELECT COUNT(*) FROM telecom_churn 
        WHERE contract = p_segment
    );
    RAISE NOTICE 'Churn rate: %', (
        SELECT ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
        FROM telecom_churn WHERE contract = p_segment
    );
END;
$$;

-- Usage: CALL sp_segment_report('Month-to-month');

-- ============================================================
-- SECTION 3: TRANSACTIONS
-- ============================================================

-- Transaction 1: Batch update with rollback protection
DO $$
DECLARE
    v_updated INT;
BEGIN
    -- Start implicit transaction
    
    -- Update high-risk customers
    UPDATE telecom_churn
    SET churn_score = LEAST(churn_score + 10, 100)
    WHERE contract = 'Month-to-month'
        AND tenure_months <= 12
        AND churn_label = 'No';
    
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RAISE NOTICE 'Updated % high-risk customers', v_updated;
    
    -- Verify update
    IF v_updated = 0 THEN
        RAISE WARNING 'No customers were updated';
    END IF;
    
    -- Transaction commits automatically at end of block
END $$;

-- Transaction 2: Savepoint usage
DO $$
BEGIN
    -- First update
    UPDATE telecom_churn SET churn_score = churn_score - 5 
    WHERE churn_label = 'No';
    
    SAVEPOINT sp1;
    
    -- Second update (might fail)
    BEGIN
        UPDATE telecom_churn SET churn_score = churn_score + 20 
        WHERE contract = 'Month-to-month';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Second update failed, rolling back to savepoint';
        ROLLBACK TO SAVEPOINT sp1;
    END;
    
    RAISE NOTICE 'Transaction completed';
END $$;

-- ============================================================
-- SECTION 4: TRIGGERS
-- ============================================================

-- Audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    customer_id VARCHAR(50),
    old_values JSONB,
    new_values JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger function
CREATE OR REPLACE FUNCTION fn_audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, customer_id, old_values, new_values)
        VALUES (
            TG_TABLE_NAME,
            'UPDATE',
            NEW.customer_id,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, customer_id, old_values)
        VALUES (
            TG_TABLE_NAME,
            'DELETE',
            OLD.customer_id,
            to_jsonb(OLD)
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- Create trigger (disabled by default for performance)
-- CREATE TRIGGER trg_audit_telecom_churn
--     AFTER UPDATE OR DELETE ON telecom_churn
--     FOR EACH ROW
--     EXECUTE FUNCTION fn_audit_trigger();

-- ============================================================
-- SECTION 5: UTILITY QUERIES
-- ============================================================

-- List all functions
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- List all triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';
