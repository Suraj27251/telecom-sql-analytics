-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 07_indexes_optimization.sql
-- Category: Indexes and Query Optimization
-- PostgreSQL 14+ Compatible
-- ============================================================

-- ============================================================
-- SECTION 1: INDEX CREATION
-- ============================================================

-- Index 1: churn_label (high selectivity filter)
-- Why: Most analytical queries filter by churn status
CREATE INDEX IF NOT EXISTS idx_churn_label ON telecom_churn(churn_label);

-- Index 2: contract (frequent GROUP BY column)
-- Why: Contract is used in nearly every business query
CREATE INDEX IF NOT EXISTS idx_contract ON telecom_churn(contract);

-- Index 3: Composite index for contract + churn
-- Why: Covers the most common filter combination
CREATE INDEX IF NOT EXISTS idx_contract_churn ON telecom_churn(contract, churn_label);

-- Index 4: internet_service filter
-- Why: Second most common filter column
CREATE INDEX IF NOT EXISTS idx_internet_service ON telecom_churn(internet_service);

-- Index 5: monthly_charges range queries
-- Why: Range scans on charges are frequent
CREATE INDEX IF NOT EXISTS idx_monthly_charges ON telecom_churn(monthly_charges);

-- Index 6: tenure_months range queries
-- Why: Tenure bucketing requires range scans
CREATE INDEX IF NOT EXISTS idx_tenure_months ON telecom_churn(tenure_months);

-- Index 7: churn_score for risk analysis
-- Why: Risk scoring queries filter/sort by score
CREATE INDEX IF NOT EXISTS idx_churn_score ON telecom_churn(churn_score);

-- Index 8: cltv for value analysis
-- Why: Customer lifetime value segmentation
CREATE INDEX IF NOT EXISTS idx_cltv ON telecom_churn(cltv);

-- Index 9: Covering index for analytics
-- Why: Covers most SELECT columns, avoids heap fetches
CREATE INDEX IF NOT EXISTS idx_analytics_covering ON telecom_churn(
    contract, internet_service, churn_label, monthly_charges, tenure_months
);

-- Index 10: Composite for revenue analysis
-- Why: Revenue queries filter by contract and sort by charges
CREATE INDEX IF NOT EXISTS idx_revenue_analysis ON telecom_churn(
    contract, monthly_charges, churn_label
);

-- ============================================================
-- SECTION 2: PERFORMANCE TESTING (Before/After)
-- ============================================================

-- Test 1: Filter by churn_label
EXPLAIN ANALYZE
SELECT contract, COUNT(*), SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END)
FROM telecom_churn
WHERE churn_label = 'Yes'
GROUP BY contract;

-- Test 2: Range query on monthly_charges
EXPLAIN ANALYZE
SELECT customer_id, contract, monthly_charges, churn_label
FROM telecom_churn
WHERE monthly_charges BETWEEN 50 AND 100;

-- Test 3: Composite filter
EXPLAIN ANALYZE
SELECT customer_id, monthly_charges, total_charges
FROM telecom_churn
WHERE contract = 'Month-to-month' AND churn_label = 'Yes'
ORDER BY monthly_charges DESC
LIMIT 10;

-- Test 4: ORDER BY with LIMIT
EXPLAIN ANALYZE
SELECT customer_id, monthly_charges, total_charges
FROM telecom_churn
ORDER BY monthly_charges DESC
LIMIT 10;

-- Test 5: GROUP BY with filter
EXPLAIN ANALYZE
SELECT 
    contract, internet_service,
    COUNT(*), ROUND(AVG(monthly_charges), 2)
FROM telecom_churn
GROUP BY contract, internet_service;

-- ============================================================
-- SECTION 3: QUERY REWRITING FOR PERFORMANCE
-- ============================================================

-- Rewrite 1: Correlated subquery -> Window function
-- Before (slow):
-- SELECT customer_id, contract, monthly_charges,
--     (SELECT AVG(monthly_charges) FROM telecom_churn WHERE contract = t1.contract) AS avg_charge
-- FROM telecom_churn t1 WHERE monthly_charges > 70;

-- After (fast):
EXPLAIN ANALYZE
SELECT customer_id, contract, monthly_charges,
    AVG(monthly_charges) OVER (PARTITION BY contract) AS avg_charge
FROM telecom_churn
WHERE monthly_charges > 70;

-- Rewrite 2: Subquery in WHERE -> JOIN
-- Before:
-- SELECT * FROM telecom_churn WHERE contract IN (SELECT contract FROM telecom_churn GROUP BY contract HAVING AVG(monthly_charges) > 65);

-- After:
EXPLAIN ANALYZE
SELECT t.*
FROM telecom_churn t
INNER JOIN (
    SELECT contract FROM telecom_churn GROUP BY contract HAVING AVG(monthly_charges) > 65
) high_value ON t.contract = high_value.contract;

-- Rewrite 3: COUNT(*) with CASE -> Filtered aggregation
EXPLAIN ANALYZE
SELECT 
    contract,
    COUNT(*) FILTER (WHERE churn_label = 'Yes') AS churned,
    COUNT(*) FILTER (WHERE churn_label = 'No') AS active,
    COUNT(*) AS total
FROM telecom_churn
GROUP BY contract;

-- ============================================================
-- SECTION 4: INDEX MAINTENANCE
-- ============================================================

-- List all indexes
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'telecom_churn'
ORDER BY indexname;

-- Table statistics
ANALYZE telecom_churn;

-- Check table stats
SELECT 
    relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'telecom_churn';

-- Unused index detection
SELECT 
    indexrelname AS index_name,
    idx_scan AS times_used,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE ui.relname = 'telecom_churn'
ORDER BY idx_scan ASC;
