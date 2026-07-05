-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 09_advanced_analytics.sql
-- Category: Advanced SQL (Pivoting, String/Date Functions, Complex Analytics)
-- PostgreSQL 14+ Compatible
-- ============================================================

-- ============================================================
-- SECTION 1: STRING FUNCTIONS
-- ============================================================

-- Query 1: Extract area code from zip code
SELECT 
    customer_id,
    city,
    zip_code,
    SUBSTRING(zip_code FROM 1 FOR 3) AS area_code,
    LENGTH(city) AS city_name_length,
    UPPER(city) AS city_upper,
    INITCAP(city) AS city_title_case
FROM telecom_churn
LIMIT 10;

-- Query 2: Parse churn reason keywords
SELECT 
    customer_id,
    churn_reason,
    CASE 
        WHEN churn_reason ILIKE '%price%' OR churn_reason ILIKE '%charge%' THEN 'Price-related'
        WHEN churn_reason ILIKE '%competitor%' THEN 'Competitor'
        WHEN churn_reason ILIKE '%service%' OR churn_reason ILIKE '%support%' THEN 'Service'
        WHEN churn_reason ILIKE '%move%' OR churn_reason ILIKE '%relocat%' THEN 'Relocation'
        ELSE 'Other'
    END AS reason_category,
    LENGTH(churn_reason) AS reason_length
FROM telecom_churn
WHERE churn_label = 'Yes' AND churn_reason IS NOT NULL
LIMIT 15;

-- Query 3: Customer ID pattern analysis
SELECT 
    customer_id,
    SUBSTRING(customer_id FROM 1 FOR 4) AS id_prefix,
    SUBSTRING(customer_id FROM 5) AS id_suffix,
    LENGTH(customer_id) AS id_length
FROM telecom_churn
LIMIT 10;

-- ============================================================
-- SECTION 2: CASE EXPRESSIONS
-- ============================================================

-- Query 4: Complex tiered pricing analysis
SELECT 
    customer_id,
    contract,
    monthly_charges,
    CASE 
        WHEN monthly_charges < 20 THEN 'Budget'
        WHEN monthly_charges < 40 THEN 'Basic'
        WHEN monthly_charges < 60 THEN 'Standard'
        WHEN monthly_charges < 80 THEN 'Premium'
        WHEN monthly_charges < 100 THEN 'Enterprise'
        ELSE 'Ultimate'
    END AS pricing_tier,
    CASE 
        WHEN tenure_months < 6 THEN 'New'
        WHEN tenure_months < 12 THEN 'Developing'
        WHEN tenure_months < 24 THEN 'Established'
        WHEN tenure_months < 48 THEN 'Loyal'
        ELSE 'Veteran'
    END AS loyalty_tier,
    CASE 
        WHEN churn_label = 'Yes' THEN 'Churned'
        WHEN churn_score >= 70 THEN 'At Risk'
        WHEN churn_score >= 40 THEN 'Watch'
        ELSE 'Healthy'
    END AS health_status
FROM telecom_churn
LIMIT 15;

-- Query 5: Service maturity score
SELECT 
    customer_id,
    (
        CASE WHEN phone_service = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN internet_service != 'No' THEN 1 ELSE 0 END +
        CASE WHEN online_security = 'Yes' THEN 2 ELSE 0 END +
        CASE WHEN online_backup = 'Yes' THEN 2 ELSE 0 END +
        CASE WHEN device_protection = 'Yes' THEN 2 ELSE 0 END +
        CASE WHEN tech_support = 'Yes' THEN 2 ELSE 0 END +
        CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END
    ) AS service_score,
    monthly_charges,
    churn_label
FROM telecom_churn
ORDER BY service_score DESC
LIMIT 15;

-- ============================================================
-- SECTION 3: COALESCE AND NULLIF
-- ============================================================

-- Query 6: Handle NULL total charges
SELECT 
    customer_id,
    tenure_months,
    monthly_charges,
    COALESCE(total_charges, 0) AS total_charges_safe,
    COALESCE(total_charges, tenure_months * monthly_charges) AS estimated_total,
    NULLIF(total_charges, 0) AS null_if_zero
FROM telecom_churn
WHERE total_charges IS NULL OR total_charges = 0
LIMIT 10;

-- Query 7: Safe division with NULLIF
SELECT 
    contract,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(SUM(monthly_charges) / NULLIF(COUNT(*), 0), 2) AS safe_avg
FROM telecom_churn
GROUP BY contract;

-- ============================================================
-- SECTION 4: PIVOTING (Crosstab)
-- ============================================================

-- Query 8: Pivot churn by contract type
SELECT 
    contract,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    SUM(CASE WHEN churn_label = 'No' THEN 1 ELSE 0 END) AS active,
    COUNT(*) AS total
FROM telecom_churn
GROUP BY contract;

-- Query 9: Pivot internet service by contract
SELECT 
    contract,
    SUM(CASE WHEN internet_service = 'DSL' THEN 1 ELSE 0 END) AS dsl_count,
    SUM(CASE WHEN internet_service = 'Fiber optic' THEN 1 ELSE 0 END) AS fiber_count,
    SUM(CASE WHEN internet_service = 'No' THEN 1 ELSE 0 END) AS no_internet_count
FROM telecom_churn
GROUP BY contract;

-- Query 10: Pivot payment methods by churn status
SELECT 
    churn_label,
    SUM(CASE WHEN payment_method = 'Electronic check' THEN 1 ELSE 0 END) AS electronic_check,
    SUM(CASE WHEN payment_method = 'Mailed check' THEN 1 ELSE 0 END) AS mailed_check,
    SUM(CASE WHEN payment_method = 'Bank transfer (automatic)' THEN 1 ELSE 0 END) AS bank_transfer,
    SUM(CASE WHEN payment_method = 'Credit card (automatic)' THEN 1 ELSE 0 END) AS credit_card
FROM telecom_churn
GROUP BY churn_label;

-- ============================================================
-- SECTION 5: AGGREGATE FUNCTIONS
-- ============================================================

-- Query 11: Statistical analysis of charges
SELECT 
    COUNT(*) AS n,
    ROUND(AVG(monthly_charges), 2) AS mean,
    ROUND(STDDEV(monthly_charges), 2) AS std_dev,
    ROUND(VARIANCE(monthly_charges), 2) AS variance,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY monthly_charges) AS median,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY monthly_charges) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monthly_charges) AS q3,
    MODE() WITHIN GROUP (ORDER BY monthly_charges) AS mode
FROM telecom_churn;

-- Query 12: Percentile analysis by contract
SELECT 
    contract,
    COUNT(*) AS n,
    ROUND(AVG(monthly_charges), 2) AS mean,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY monthly_charges) AS median,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY monthly_charges) AS p90,
    MIN(monthly_charges) AS min_charge,
    MAX(monthly_charges) AS max_charge
FROM telecom_churn
GROUP BY contract;

-- ============================================================
-- SECTION 6: COMPLEX ANALYTICS
-- ============================================================

-- Query 13: Customer cohort analysis
WITH cohort AS (
    SELECT 
        customer_id,
        CASE 
            WHEN tenure_months BETWEEN 0 AND 12 THEN '2023 Cohort'
            WHEN tenure_months BETWEEN 13 AND 24 THEN '2022 Cohort'
            WHEN tenure_months BETWEEN 25 AND 36 THEN '2021 Cohort'
            ELSE '2020 or Earlier'
        END AS tenure_cohort,
        monthly_charges,
        total_charges,
        churn_label,
        cltv
    FROM telecom_churn
)
SELECT 
    tenure_cohort,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(total_charges), 2) AS avg_total,
    ROUND(AVG(cltv), 0) AS avg_cltv,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM cohort
GROUP BY tenure_cohort
ORDER BY tenure_cohort;

-- Query 14: Revenue contribution by segment
WITH revenue_contrib AS (
    SELECT 
        customer_id,
        contract,
        monthly_charges,
        SUM(monthly_charges) OVER () AS grand_total,
        SUM(monthly_charges) OVER (PARTITION BY contract) AS contract_total
    FROM telecom_churn
)
SELECT DISTINCT
    contract,
    ROUND(contract_total, 2) AS contract_revenue,
    ROUND(contract_total * 100.0 / grand_total, 2) AS pct_of_total
FROM revenue_contrib
ORDER BY contract_revenue DESC;

-- Query 15: Churn velocity analysis
WITH churn_velocity AS (
    SELECT 
        contract,
        tenure_months,
        COUNT(*) AS customers,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY contract, tenure_months
)
SELECT 
    contract,
    tenure_months,
    customers,
    churned,
    ROUND(churned * 100.0 / customers, 2) AS churn_rate,
    SUM(churned) OVER (PARTITION BY contract ORDER BY tenure_months) AS cumulative_churn
FROM churn_velocity
WHERE contract = 'Month-to-month'
ORDER BY tenure_months;

-- Query 16: Customer similarity analysis
WITH customer_features AS (
    SELECT 
        customer_id,
        contract,
        internet_service,
        monthly_charges,
        tenure_months,
        churn_label
    FROM telecom_churn
)
SELECT 
    a.customer_id AS customer_a,
    b.customer_id AS customer_b,
    a.contract,
    a.internet_service,
    ABS(a.monthly_charges - b.monthly_charges) AS charge_diff,
    ABS(a.tenure_months - b.tenure_months) AS tenure_diff
FROM customer_features a
INNER JOIN customer_features b 
    ON a.contract = b.contract 
    AND a.internet_service = b.internet_service
    AND a.customer_id < b.customer_id
WHERE ABS(a.monthly_charges - b.monthly_charges) < 5
    AND ABS(a.tenure_months - b.tenure_months) < 3
LIMIT 10;

-- Query 17: Running metrics with multiple windows
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROW_NUMBER() OVER w AS row_num,
    SUM(monthly_charges) OVER w AS running_sum,
    AVG(monthly_charges) OVER w AS running_avg,
    MIN(monthly_charges) OVER w AS running_min,
    MAX(monthly_charges) OVER w AS running_max
FROM telecom_churn
WINDOW w AS (PARTITION BY contract ORDER BY monthly_charges)
ORDER BY contract, monthly_charges
LIMIT 20;

-- Query 18: Year-over-year comparison simulation
WITH monthly_data AS (
    SELECT 
        EXTRACT(MONTH FROM CURRENT_DATE) AS current_month,
        contract,
        COUNT(*) AS customers,
        ROUND(AVG(monthly_charges), 2) AS avg_charge,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY contract
)
SELECT 
    contract,
    customers,
    avg_charge,
    churned,
    ROUND(churned * 100.0 / customers, 2) AS churn_rate,
    RANK() OVER (ORDER BY churned * 100.0 / customers DESC) AS churn_rank
FROM monthly_data
ORDER BY churn_rate DESC;

-- Query 19: Multi-dimensional analysis
SELECT 
    contract,
    internet_service,
    payment_method,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY contract, internet_service, payment_method
HAVING COUNT(*) >= 50
ORDER BY churn_rate DESC
LIMIT 15;

-- Query 20: Final comprehensive dashboard
WITH kpis AS (
    SELECT 
        COUNT(*) AS total_customers,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
        ROUND(AVG(monthly_charges), 2) AS avg_charge,
        ROUND(SUM(monthly_charges), 2) AS total_revenue,
        ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS revenue_at_risk
    FROM telecom_churn
)
SELECT 
    'Total Customers' AS kpi, total_customers::text AS value FROM kpis
UNION ALL SELECT 'Churned Customers', churned::text FROM kpis
UNION ALL SELECT 'Churn Rate', ROUND(churned * 100.0 / total_customers, 2)::text FROM kpis
UNION ALL SELECT 'Avg Monthly Charge', avg_charge::text FROM kpis
UNION ALL SELECT 'Total Monthly Revenue', total_revenue::text FROM kpis
UNION ALL SELECT 'Revenue at Risk', revenue_at_risk::text FROM kpis
UNION ALL SELECT 'Revenue at Risk %', ROUND(revenue_at_risk * 100.0 / total_revenue, 2)::text FROM kpis;
