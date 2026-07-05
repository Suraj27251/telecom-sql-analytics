-- ============================================================
-- Telecom SQL Analytics Platform
-- Schema: validation.sql
-- PostgreSQL 14+ Compatible
-- ============================================================
-- Description: Validates the data import by checking row counts,
-- duplicates, NULLs, data types, and sample records.
-- Run this after load_data.sql to confirm successful import.
-- ============================================================

-- ============================================================
-- 1. ROW COUNT VALIDATION
-- ============================================================

SELECT 
    'Row Count' AS check_name,
    COUNT(*) AS actual_count,
    7043 AS expected_count,
    CASE 
        WHEN COUNT(*) = 7043 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM telecom_churn;

-- ============================================================
-- 2. DUPLICATE CUSTOMER CHECK
-- ============================================================

SELECT 
    'Duplicate Check' AS check_name,
    COUNT(*) AS duplicate_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM (
    SELECT customer_id, COUNT(*) AS cnt
    FROM telecom_churn
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) duplicates;

-- Show duplicate details if any
SELECT customer_id, COUNT(*) AS occurrences
FROM telecom_churn
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- ============================================================
-- 3. NULL CHECK - Critical Columns
-- ============================================================

SELECT 
    'NULL Check' AS check_name,
    column_name,
    null_count,
    total_rows,
    CASE 
        WHEN null_count = 0 THEN 'PASS'
        ELSE 'WARN'
    END AS status
FROM (
    SELECT 'customer_id' AS column_name, SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_count, COUNT(*) AS total_rows FROM telecom_churn
    UNION ALL
    SELECT 'gender', SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM telecom_churn
    UNION ALL
    SELECT 'contract', SUM(CASE WHEN contract IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM telecom_churn
    UNION ALL
    SELECT 'monthly_charges', SUM(CASE WHEN monthly_charges IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM telecom_churn
    UNION ALL
    SELECT 'total_charges', SUM(CASE WHEN total_charges IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM telecom_churn
    UNION ALL
    SELECT 'churn_label', SUM(CASE WHEN churn_label IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM telecom_churn
    UNION ALL
    SELECT 'churn_reason', SUM(CASE WHEN churn_reason IS NULL THEN 1 ELSE 0 END), COUNT(*) FROM telecom_churn
) null_checks
ORDER BY null_count DESC;

-- ============================================================
-- 4. DATA TYPE VALIDATION
-- ============================================================

-- Check tenure_months range
SELECT 
    'Tenure Range' AS check_name,
    MIN(tenure_months) AS min_value,
    MAX(tenure_months) AS max_value,
    CASE 
        WHEN MIN(tenure_months) >= 0 AND MAX(tenure_months) <= 72 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM telecom_churn;

-- Check monthly_charges range
SELECT 
    'Monthly Charges Range' AS check_name,
    MIN(monthly_charges) AS min_value,
    MAX(monthly_charges) AS max_value,
    CASE 
        WHEN MIN(monthly_charges) >= 0 AND MAX(monthly_charges) <= 200 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM telecom_churn;

-- Check churn_label values
SELECT 
    'Churn Label Values' AS check_name,
    churn_label,
    COUNT(*) AS cnt
FROM telecom_churn
GROUP BY churn_label;

-- Check gender values
SELECT 
    'Gender Values' AS check_name,
    gender,
    COUNT(*) AS cnt
FROM telecom_churn
GROUP BY gender;

-- Check contract values
SELECT 
    'Contract Values' AS check_name,
    contract,
    COUNT(*) AS cnt
FROM telecom_churn
GROUP BY contract;

-- ============================================================
-- 5. REFERENTIAL INTEGRITY CHECKS
-- ============================================================

-- Check for orphaned records (all should have customer_id)
SELECT 
    'Orphan Check' AS check_name,
    COUNT(*) AS orphan_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM telecom_churn
WHERE customer_id IS NULL OR customer_id = '';

-- ============================================================
-- 6. BUSINESS LOGIC VALIDATION
-- ============================================================

-- churn_label and churn_value should be consistent
SELECT 
    'Churn Consistency' AS check_name,
    COUNT(*) AS inconsistent_count,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM telecom_churn
WHERE (churn_label = 'Yes' AND churn_value != 1)
   OR (churn_label = 'No' AND churn_value != 0);

-- ============================================================
-- 7. SAMPLE RECORDS
-- ============================================================

-- First 5 records
SELECT 
    customer_id, gender, senior_citizen, partner, dependents,
    tenure_months, contract, internet_service, monthly_charges,
    total_charges, churn_label, churn_reason
FROM telecom_churn
LIMIT 5;

-- Last 5 records
SELECT 
    customer_id, gender, senior_citizen, partner, dependents,
    tenure_months, contract, internet_service, monthly_charges,
    total_charges, churn_label, churn_reason
FROM telecom_churn
ORDER BY customer_id DESC
LIMIT 5;

-- Random sample
SELECT 
    customer_id, gender, senior_citizen, partner, dependents,
    tenure_months, contract, internet_service, monthly_charges,
    total_charges, churn_label, churn_reason
FROM telecom_churn
ORDER BY RANDOM()
LIMIT 5;

-- ============================================================
-- 8. SUMMARY STATISTICS
-- ============================================================

SELECT 
    'Summary Statistics' AS check_name,
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,
    ROUND(AVG(total_charges), 2) AS avg_total_charges,
    ROUND(AVG(tenure_months), 1) AS avg_tenure_months,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned_count,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn;

-- ============================================================
-- 9. CHURN REASON DISTRIBUTION
-- ============================================================

SELECT 
    churn_reason,
    COUNT(*) AS reason_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM telecom_churn
WHERE churn_label = 'Yes' AND churn_reason IS NOT NULL
GROUP BY churn_reason
ORDER BY reason_count DESC;

-- ============================================================
-- 10. FINAL VALIDATION SUMMARY
-- ============================================================

DO $$
DECLARE
    v_total_rows INTEGER;
    v_duplicates INTEGER;
    v_null_customer_id INTEGER;
    v_inconsistent_churn INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_rows FROM telecom_churn;
    
    SELECT COUNT(*) INTO v_duplicates FROM (
        SELECT customer_id FROM telecom_churn GROUP BY customer_id HAVING COUNT(*) > 1
    ) d;
    
    SELECT COUNT(*) INTO v_null_customer_id FROM telecom_churn WHERE customer_id IS NULL;
    
    SELECT COUNT(*) INTO v_inconsistent_churn FROM telecom_churn
    WHERE (churn_label = 'Yes' AND churn_value != 1)
       OR (churn_label = 'No' AND churn_value != 0);
    
    RAISE NOTICE '============================================';
    RAISE NOTICE 'VALIDATION SUMMARY';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Total rows: % (expected: 7043)', v_total_rows;
    RAISE NOTICE 'Duplicate customer IDs: % (expected: 0)', v_duplicates;
    RAISE NOTICE 'NULL customer IDs: % (expected: 0)', v_null_customer_id;
    RAISE NOTICE 'Inconsistent churn records: % (expected: 0)', v_inconsistent_churn;
    RAISE NOTICE '============================================';
    
    IF v_total_rows = 7043 AND v_duplicates = 0 AND v_null_customer_id = 0 AND v_inconsistent_churn = 0 THEN
        RAISE NOTICE 'ALL CHECKS PASSED';
    ELSE
        RAISE WARNING 'SOME CHECKS FAILED - Review above details';
    END IF;
END $$;
