-- ============================================================
-- Telecom SQL Analytics Platform
-- Schema: load_data.sql
-- PostgreSQL 14+ Compatible
-- ============================================================
-- Description: Imports telecom_churn.csv into the database.
-- IMPORTANT: The CSV has 11 rows with empty total_charges.
--            A cleaned version is provided as telecom_churn_clean.csv.
-- ============================================================

-- ============================================================
-- PRE-FLIGHT CHECKS
-- ============================================================

-- Verify table exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'telecom_churn') THEN
        RAISE EXCEPTION 'Table telecom_churn does not exist. Run create_tables.sql first.';
    END IF;
    RAISE NOTICE 'Table telecom_churn found. Proceeding with data load.';
END $$;

-- Check if data already loaded
DO $$
DECLARE
    v_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM telecom_churn;
    IF v_count > 0 THEN
        RAISE WARNING 'Table already has % rows. Truncating before reload.', v_count;
        TRUNCATE TABLE telecom_churn;
    END IF;
END $$;

-- ============================================================
-- METHOD A: COMMAND LINE (Recommended)
-- ============================================================
-- Open PowerShell or Command Prompt and run:
--
--   psql -U postgres -d telecom_analytics_v2 -c "\copy telecom_churn FROM 'C:/path/to/telecom-sql-analytics/data/telecom_churn_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')"
--
-- Or connect to psql first:
--   psql -U postgres -d telecom_analytics_v2
--   \copy telecom_churn FROM 'C:/path/to/telecom-sql-analytics/data/telecom_churn_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')

-- ============================================================
-- METHOD B: PYTHON SCRIPT (Most Reliable)
-- ============================================================
-- Save this as load_data.py in the schema/ folder and run:
--   python load_data.py
--
-- Requirements: pip install psycopg2-binary

-- ============================================================
-- METHOD C: PGADMIN QUERY TOOL
-- ============================================================
-- Open pgAdmin -> Query Tool -> Open load_data.sql
-- Uncomment and run the COPY command below (adjust path):
--
-- COPY telecom_churn FROM 'C:/Users/suraj/OneDrive/Desktop/telecom-sql-analytics/data/telecom_churn_clean.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- ============================================================
-- POST-LOAD: Update statistics
-- ============================================================

ANALYZE telecom_churn;

-- ============================================================
-- QUICK VERIFICATION
-- ============================================================

SELECT COUNT(*) AS total_rows FROM telecom_churn;
SELECT customer_id, gender, contract, monthly_charges, churn_label 
FROM telecom_churn 
LIMIT 5;
