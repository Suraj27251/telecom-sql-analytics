-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 03_subqueries.sql
-- Category: Subqueries (Correlated, Scalar, EXISTS, IN)
-- PostgreSQL 14+ Compatible
-- ============================================================
-- This file contains 25 subquery patterns including correlated
-- subqueries, scalar subqueries, EXISTS/NOT EXISTS, and IN
-- with subqueries for segment comparisons.
-- ============================================================

-- ============================================================
-- SECTION 1: CORRELATED SUBQUERIES IN SELECT (Queries 1-5)
-- ============================================================

-- Query 1: Customer charges vs contract average
SELECT 
    customer_id,
    contract,
    monthly_charges,
    (
        SELECT ROUND(AVG(t2.monthly_charges), 2)
        FROM telecom_churn t2
        WHERE t2.contract = t1.contract
    ) AS contract_avg,
    ROUND(
        t1.monthly_charges - (
            SELECT AVG(t2.monthly_charges)
            FROM telecom_churn t2
            WHERE t2.contract = t1.contract
        ), 2
    ) AS diff_from_avg,
    CASE 
        WHEN t1.monthly_charges > (
            SELECT AVG(t2.monthly_charges)
            FROM telecom_churn t2
            WHERE t2.contract = t1.contract
        ) THEN 'Above Average'
        ELSE 'Below Average'
    END AS status
FROM telecom_churn t1
ORDER BY contract, monthly_charges DESC;

-- Query 2: Customer charges vs internet service average
SELECT 
    customer_id,
    internet_service,
    monthly_charges,
    (
        SELECT ROUND(AVG(t2.monthly_charges), 2)
        FROM telecom_churn t2
        WHERE t2.internet_service = t1.internet_service
    ) AS internet_service_avg
FROM telecom_churn t1
WHERE t1.monthly_charges > (
    SELECT AVG(t2.monthly_charges)
    FROM telecom_churn t2
    WHERE t2.internet_service = t1.internet_service
)
ORDER BY internet_service, monthly_charges DESC;

-- Query 3: CLTV vs contract average
SELECT 
    customer_id,
    contract,
    cltv,
    (
        SELECT ROUND(AVG(t2.cltv), 0)
        FROM telecom_churn t2
        WHERE t2.contract = t1.contract
    ) AS contract_avg_cltv
FROM telecom_churn t1
WHERE t1.cltv > (
    SELECT AVG(t2.cltv)
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
)
ORDER BY contract, cltv DESC;

-- Query 4: Charges vs payment method average
SELECT 
    customer_id,
    payment_method,
    monthly_charges,
    (
        SELECT ROUND(AVG(t2.monthly_charges), 2)
        FROM telecom_churn t2
        WHERE t2.payment_method = t1.payment_method
    ) AS payment_method_avg
FROM telecom_churn t1
WHERE t1.monthly_charges > (
    SELECT AVG(t2.monthly_charges)
    FROM telecom_churn t2
    WHERE t2.payment_method = t1.payment_method
)
ORDER BY payment_method, monthly_charges DESC;

-- Query 5: Tenure vs contract average
SELECT 
    customer_id,
    contract,
    tenure_months,
    (
        SELECT ROUND(AVG(t2.tenure_months), 1)
        FROM telecom_churn t2
        WHERE t2.contract = t1.contract
    ) AS contract_avg_tenure
FROM telecom_churn t1
WHERE t1.tenure_months > (
    SELECT AVG(t2.tenure_months)
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
)
ORDER BY contract, tenure_months DESC;

-- ============================================================
-- SECTION 2: CORRELATED SUBQUERIES IN WHERE (Queries 6-10)
-- ============================================================

-- Query 6: Customers above segment average (contract + internet)
SELECT 
    customer_id,
    contract,
    internet_service,
    monthly_charges,
    (
        SELECT ROUND(AVG(t2.monthly_charges), 2)
        FROM telecom_churn t2
        WHERE t2.contract = t1.contract
            AND t2.internet_service = t1.internet_service
    ) AS segment_avg
FROM telecom_churn t1
WHERE t1.monthly_charges > (
    SELECT AVG(t2.monthly_charges)
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
        AND t2.internet_service = t1.internet_service
)
ORDER BY contract, internet_service, monthly_charges DESC;

-- Query 7: Customers with above-average CLTV for gender
SELECT 
    customer_id,
    gender,
    total_charges,
    (
        SELECT ROUND(AVG(t2.total_charges), 2)
        FROM telecom_churn t2
        WHERE t2.gender = t1.gender
    ) AS gender_avg_total
FROM telecom_churn t1
WHERE t1.total_charges > (
    SELECT AVG(t2.total_charges)
    FROM telecom_churn t2
    WHERE t2.gender = t1.gender
)
ORDER BY gender, total_charges DESC;

-- Query 8: Customers with above-average churn score
SELECT 
    customer_id,
    contract,
    churn_score,
    (
        SELECT ROUND(AVG(t2.churn_score), 1)
        FROM telecom_churn t2
        WHERE t2.contract = t1.contract
    ) AS contract_avg_score
FROM telecom_churn t1
WHERE t1.churn_score > (
    SELECT AVG(t2.churn_score)
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
)
ORDER BY contract, churn_score DESC;

-- Query 9: Customers in high-churn cities
SELECT 
    customer_id,
    city,
    monthly_charges,
    churn_label
FROM telecom_churn t1
WHERE (
    SELECT COUNT(*)
    FROM telecom_churn t2
    WHERE t2.city = t1.city
        AND t2.churn_label = 'Yes'
) > 5
ORDER BY city, monthly_charges DESC;

-- Query 10: Customers paying more than city average
SELECT 
    customer_id,
    city,
    monthly_charges,
    (
        SELECT ROUND(AVG(t2.monthly_charges), 2)
        FROM telecom_churn t2
        WHERE t2.city = t1.city
    ) AS city_avg_charge
FROM telecom_churn t1
WHERE t1.monthly_charges > (
    SELECT AVG(t2.monthly_charges)
    FROM telecom_churn t2
    WHERE t2.city = t1.city
)
ORDER BY city, monthly_charges DESC;

-- ============================================================
-- SECTION 3: EXISTS / NOT EXISTS (Queries 11-15)
-- ============================================================

-- Query 11: Customers with at least one add-on service
SELECT 
    customer_id,
    online_security,
    online_backup,
    device_protection,
    tech_support
FROM telecom_churn t1
WHERE t1.online_security = 'Yes'
    OR t1.online_backup = 'Yes'
    OR t1.device_protection = 'Yes'
    OR t1.tech_support = 'Yes'
ORDER BY customer_id;

-- Query 12: Customers with NO add-on services
SELECT 
    customer_id,
    online_security,
    online_backup,
    device_protection,
    tech_support
FROM telecom_churn t1
WHERE t1.online_security = 'No'
    AND t1.online_backup = 'No'
    AND t1.device_protection = 'No'
    AND t1.tech_support = 'No'
ORDER BY customer_id;

-- Query 13: EXISTS - Customers with streaming but no security
SELECT 
    customer_id,
    streaming_tv,
    streaming_movies,
    online_security,
    tech_support
FROM telecom_churn t1
WHERE (t1.streaming_tv = 'Yes' OR t1.streaming_movies = 'Yes')
    AND t1.online_security = 'No'
ORDER BY customer_id;

-- Query 14: NOT EXISTS - Customers without any streaming
SELECT 
    customer_id,
    streaming_tv,
    streaming_movies,
    internet_service
FROM telecom_churn t1
WHERE t1.streaming_tv = 'No'
    AND t1.streaming_movies = 'No'
ORDER BY customer_id;

-- Query 15: EXISTS with correlated condition - Fiber customers with security
SELECT 
    customer_id,
    internet_service,
    online_security,
    tech_support,
    monthly_charges
FROM telecom_churn t1
WHERE t1.internet_service = 'Fiber optic'
    AND EXISTS (
        SELECT 1
        FROM telecom_churn t2
        WHERE t2.customer_id = t1.customer_id
            AND t2.online_security = 'Yes'
    )
ORDER BY monthly_charges DESC;

-- ============================================================
-- SECTION 4: IN / NOT IN WITH SUBQUERIES (Queries 16-19)
-- ============================================================

-- Query 16: Customers in high-value contracts
SELECT 
    customer_id,
    contract,
    monthly_charges,
    total_charges
FROM telecom_churn
WHERE contract IN (
    SELECT contract
    FROM telecom_churn
    GROUP BY contract
    HAVING AVG(monthly_charges) > 65
)
ORDER BY contract, monthly_charges DESC;

-- Query 17: Customers NOT in month-to-month contract
SELECT 
    customer_id,
    contract,
    monthly_charges,
    tenure_months
FROM telecom_churn
WHERE contract NOT IN ('Month-to-month')
ORDER BY contract, monthly_charges DESC;

-- Query 18: Customers in cities with above-average churn
SELECT 
    customer_id,
    city,
    monthly_charges,
    churn_label
FROM telecom_churn
WHERE city IN (
    SELECT city
    FROM telecom_churn
    GROUP BY city
    HAVING 
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END)::float / COUNT(*) > 0.3
        AND COUNT(*) >= 20
)
ORDER BY city, monthly_charges DESC;

-- Query 19: Customers with top payment methods by churn
SELECT 
    customer_id,
    payment_method,
    monthly_charges,
    churn_label
FROM telecom_churn
WHERE payment_method IN (
    SELECT payment_method
    FROM telecom_churn
    GROUP BY payment_method
    HAVING 
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END)::float / COUNT(*) > 0.3
)
ORDER BY payment_method, monthly_charges DESC;

-- ============================================================
-- SECTION 5: SCALAR SUBQUERIES (Queries 20-22)
-- ============================================================

-- Query 20: Customer charges vs overall average
SELECT 
    customer_id,
    contract,
    monthly_charges,
    (SELECT ROUND(AVG(monthly_charges), 2) FROM telecom_churn) AS overall_avg,
    ROUND(
        t1.monthly_charges - (SELECT AVG(monthly_charges) FROM telecom_churn), 2
    ) AS diff_from_overall
FROM telecom_churn t1
ORDER BY monthly_charges DESC;

-- Query 21: Customer tenure vs overall average
SELECT 
    customer_id,
    contract,
    tenure_months,
    (SELECT ROUND(AVG(tenure_months), 1) FROM telecom_churn) AS overall_avg_tenure,
    ROUND(
        t1.tenure_months - (SELECT AVG(tenure_months) FROM telecom_churn), 1
    ) AS diff_from_overall
FROM telecom_churn t1
ORDER BY tenure_months DESC;

-- Query 22: Customer CLTV vs overall average
SELECT 
    customer_id,
    contract,
    cltv,
    (SELECT ROUND(AVG(cltv), 0) FROM telecom_churn) AS overall_avg_cltv,
    t1.cltv - (SELECT AVG(cltv) FROM telecom_churn) AS diff_from_overall
FROM telecom_churn t1
ORDER BY cltv DESC;

-- ============================================================
-- SECTION 6: ADVANCED SUBQUERY PATTERNS (Queries 23-25)
-- ============================================================

-- Query 23: Customers with charges in top 10% of their contract
SELECT 
    customer_id,
    contract,
    monthly_charges
FROM telecom_churn t1
WHERE monthly_charges > (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY monthly_charges)
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
)
ORDER BY contract, monthly_charges DESC;

-- Query 24: Customers with most services in their segment
SELECT 
    customer_id,
    contract,
    internet_service,
    (
        CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END
    ) AS add_on_count,
    monthly_charges
FROM telecom_churn t1
WHERE (
    CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END +
    CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END +
    CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
    CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END +
    CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END +
    CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END
) > (
    SELECT AVG(
        CASE WHEN t2.online_security = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN t2.online_backup = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN t2.device_protection = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN t2.tech_support = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN t2.streaming_tv = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN t2.streaming_movies = 'Yes' THEN 1 ELSE 0 END
    )
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
)
ORDER BY contract, add_on_count DESC;

-- Query 25: Customers with churn score above their segment average
SELECT 
    customer_id,
    contract,
    internet_service,
    churn_score,
    monthly_charges,
    (
        SELECT ROUND(AVG(t2.churn_score), 1)
        FROM telecom_churn t2
        WHERE t2.contract = t1.contract
            AND t2.internet_service = t1.internet_service
    ) AS segment_avg_score
FROM telecom_churn t1
WHERE t1.churn_score > (
    SELECT AVG(t2.churn_score)
    FROM telecom_churn t2
    WHERE t2.contract = t1.contract
        AND t2.internet_service = t1.internet_service
)
ORDER BY contract, internet_service, churn_score DESC;
