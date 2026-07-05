-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 04_cte.sql
-- Category: Common Table Expressions (Basic, Recursive, Multi-level)
-- PostgreSQL 14+ Compatible
-- ============================================================
-- This file contains 25 CTE queries covering basic CTEs,
-- recursive CTEs, multiple CTEs in a single query, and
-- CTEs for complex transformations.
-- ============================================================

-- ============================================================
-- SECTION 1: BASIC CTEs (Queries 1-6)
-- ============================================================

-- Query 1: Customer segments by tenure
WITH tenure_segments AS (
    SELECT 
        customer_id,
        tenure_months,
        monthly_charges,
        total_charges,
        churn_label,
        CASE 
            WHEN tenure_months <= 12 THEN 'New (0-12 months)'
            WHEN tenure_months <= 36 THEN 'Established (13-36 months)'
            WHEN tenure_months <= 60 THEN 'Loyal (37-60 months)'
            ELSE 'Veteran (60+ months)'
        END AS tenure_segment
    FROM telecom_churn
)
SELECT 
    tenure_segment,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM tenure_segments
GROUP BY tenure_segment
ORDER BY churn_rate DESC;

-- Query 2: Revenue analysis by contract
WITH contract_revenue AS (
    SELECT 
        contract,
        COUNT(*) AS customer_count,
        SUM(monthly_charges) AS total_monthly_revenue,
        SUM(total_charges) AS total_lifetime_revenue,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY contract
)
SELECT 
    contract,
    customer_count,
    total_monthly_revenue,
    total_lifetime_revenue,
    avg_monthly_charge,
    churned,
    ROUND(churned * 100.0 / customer_count, 2) AS churn_rate,
    ROUND(total_monthly_revenue / customer_count, 2) AS revenue_per_customer
FROM contract_revenue
ORDER BY total_monthly_revenue DESC;

-- Query 3: Churn reason analysis
WITH churn_reasons AS (
    SELECT 
        churn_reason,
        COUNT(*) AS reason_count,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
        ROUND(AVG(tenure_months), 1) AS avg_tenure,
        ROUND(AVG(total_charges), 2) AS avg_total_charges
    FROM telecom_churn
    WHERE churn_label = 'Yes' AND churn_reason IS NOT NULL
    GROUP BY churn_reason
)
SELECT 
    churn_reason,
    reason_count,
    avg_monthly_charge,
    avg_tenure,
    avg_total_charges,
    ROUND(reason_count * 100.0 / SUM(reason_count) OVER (), 2) AS percentage
FROM churn_reasons
ORDER BY reason_count DESC;

-- Query 4: Service adoption analysis
WITH service_analysis AS (
    SELECT 
        customer_id,
        online_security,
        online_backup,
        device_protection,
        tech_support,
        streaming_tv,
        streaming_movies,
        monthly_charges,
        churn_label,
        (
            CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END
        ) AS add_on_count
    FROM telecom_churn
)
SELECT 
    add_on_count,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge
FROM service_analysis
GROUP BY add_on_count
ORDER BY add_on_count;

-- Query 5: Payment method effectiveness
WITH payment_analysis AS (
    SELECT 
        payment_method,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
        ROUND(AVG(tenure_months), 1) AS avg_tenure,
        ROUND(AVG(total_charges), 2) AS avg_total_charges
    FROM telecom_churn
    GROUP BY payment_method
)
SELECT 
    payment_method,
    total_customers,
    churned,
    ROUND(churned * 100.0 / total_customers, 2) AS churn_rate,
    avg_monthly_charge,
    avg_tenure,
    avg_total_charges,
    RANK() OVER (ORDER BY churned * 100.0 / total_customers DESC) AS churn_risk_rank
FROM payment_analysis
ORDER BY churn_rate DESC;

-- Query 6: Internet service impact by contract
WITH internet_impact AS (
    SELECT 
        internet_service,
        contract,
        COUNT(*) AS customer_count,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY internet_service, contract
)
SELECT 
    internet_service,
    contract,
    customer_count,
    avg_monthly_charge,
    churned,
    ROUND(churned * 100.0 / customer_count, 2) AS churn_rate
FROM internet_impact
ORDER BY internet_service, churn_rate DESC;

-- ============================================================
-- SECTION 2: MULTI-LEVEL CTEs (Queries 7-10)
-- ============================================================

-- Query 7: Customer risk assessment (3 CTE levels)
WITH customer_metrics AS (
    SELECT 
        customer_id,
        contract,
        tenure_months,
        monthly_charges,
        total_charges,
        churn_label,
        churn_score,
        cltv,
        CASE 
            WHEN churn_score >= 70 THEN 'High Risk'
            WHEN churn_score >= 40 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_level,
        CASE 
            WHEN cltv >= 5000 THEN 'High Value'
            WHEN cltv >= 3000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_tier
    FROM telecom_churn
),
risk_summary AS (
    SELECT 
        risk_level,
        value_tier,
        COUNT(*) AS customer_count,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,
        ROUND(AVG(churn_score), 1) AS avg_churn_score,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM customer_metrics
    GROUP BY risk_level, value_tier
)
SELECT 
    risk_level,
    value_tier,
    customer_count,
    avg_monthly_charges,
    avg_churn_score,
    churned,
    ROUND(churned * 100.0 / customer_count, 2) AS churn_rate
FROM risk_summary
ORDER BY risk_level, value_tier;

-- Query 8: Comprehensive customer profile
WITH customer_profile AS (
    SELECT 
        c.customer_id,
        c.gender,
        c.senior_citizen,
        c.partner,
        c.tenure_months,
        c.contract,
        c.monthly_charges,
        c.total_charges,
        c.churn_label,
        c.churn_score,
        c.cltv,
        CASE 
            WHEN c.tenure_months <= 12 AND c.monthly_charges > 70 THEN 'New High-Paying'
            WHEN c.tenure_months > 36 AND c.monthly_charges > 70 THEN 'Loyal High-Paying'
            WHEN c.tenure_months <= 12 AND c.monthly_charges <= 70 THEN 'New Low-Paying'
            ELSE 'Loyal Low-Paying'
        END AS customer_segment
    FROM telecom_churn c
)
SELECT 
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM customer_profile
GROUP BY customer_segment
ORDER BY churn_rate DESC;

-- Query 9: CLTV tiers with churn analysis
WITH cltv_tiers AS (
    SELECT 
        customer_id,
        contract,
        cltv,
        monthly_charges,
        total_charges,
        churn_label,
        CASE 
            WHEN cltv >= 5000 THEN 'Platinum'
            WHEN cltv >= 4000 THEN 'Gold'
            WHEN cltv >= 3000 THEN 'Silver'
            WHEN cltv >= 2000 THEN 'Bronze'
            ELSE 'Basic'
        END AS cltv_tier
    FROM telecom_churn
)
SELECT 
    cltv_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(total_charges), 2) AS avg_total_charges,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM cltv_tiers
GROUP BY cltv_tier
ORDER BY cltv_tier;

-- Query 10: Senior citizen comparison
WITH senior_analysis AS (
    SELECT 
        senior_citizen,
        gender,
        COUNT(*) AS customer_count,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
        ROUND(AVG(tenure_months), 1) AS avg_tenure,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY senior_citizen, gender
)
SELECT 
    senior_citizen,
    gender,
    customer_count,
    avg_monthly_charge,
    avg_tenure,
    churned,
    ROUND(churned * 100.0 / customer_count, 2) AS churn_rate
FROM senior_analysis
ORDER BY senior_citizen, gender;

-- ============================================================
-- SECTION 3: RECURSIVE CTEs (Queries 11-13)
-- ============================================================

-- Query 11: Generate date series (monthly)
WITH RECURSIVE date_series AS (
    SELECT DATE '2020-01-01' AS analysis_date
    UNION ALL
    SELECT analysis_date + INTERVAL '1 month'
    FROM date_series
    WHERE analysis_date < DATE '2023-12-31'
)
SELECT analysis_date
FROM date_series
WHERE EXTRACT(MONTH FROM analysis_date) = 1
ORDER BY analysis_date;

-- Query 12: Generate tenure buckets dynamically
WITH RECURSIVE tenure_buckets AS (
    SELECT 0 AS bucket_start, 12 AS bucket_end, '0-12 months' AS bucket_name
    UNION ALL
    SELECT bucket_end + 1, bucket_end + 12, 
        (bucket_end + 1)::text || '-' || (bucket_end + 12)::text || ' months'
    FROM tenure_buckets
    WHERE bucket_end < 72
)
SELECT bucket_start, bucket_end, bucket_name
FROM tenure_buckets
ORDER BY bucket_start;

-- Query 13: Generate charge ranges
WITH RECURSIVE charge_ranges AS (
    SELECT 0 AS range_start, 20 AS range_end, '$0-$20' AS range_name
    UNION ALL
    SELECT range_end, range_end + 20, 
        '$' || range_end::text || '-$' || (range_end + 20)::text
    FROM charge_ranges
    WHERE range_end < 120
)
SELECT range_start, range_end, range_name
FROM charge_ranges
ORDER BY range_start;

-- ============================================================
-- SECTION 4: GEOGRAPHIC ANALYSIS (Queries 14-17)
-- ============================================================

-- Query 14: City-level churn analysis
WITH city_stats AS (
    SELECT 
        city,
        COUNT(*) AS customer_count,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
        ROUND(AVG(cltv), 0) AS avg_cltv
    FROM telecom_churn
    GROUP BY city
    HAVING COUNT(*) >= 10
)
SELECT 
    city,
    customer_count,
    avg_monthly_charge,
    churned,
    ROUND(churned * 100.0 / customer_count, 2) AS churn_rate,
    avg_cltv,
    RANK() OVER (ORDER BY churned DESC) AS churn_rank
FROM city_stats
ORDER BY churned DESC
LIMIT 20;

-- Query 15: State-level summary
WITH state_summary AS (
    SELECT 
        state,
        COUNT(*) AS customer_count,
        ROUND(AVG(monthly_charges), 2) AS avg_charge,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
        ROUND(SUM(monthly_charges), 2) AS total_revenue
    FROM telecom_churn
    GROUP BY state
)
SELECT 
    state,
    customer_count,
    avg_charge,
    churned,
    ROUND(churned * 100.0 / customer_count, 2) AS churn_rate,
    total_revenue
FROM state_summary
ORDER BY total_revenue DESC;

-- Query 16: Top cities by revenue
WITH city_revenue AS (
    SELECT 
        city,
        COUNT(*) AS customers,
        ROUND(SUM(monthly_charges), 2) AS monthly_revenue,
        ROUND(AVG(monthly_charges), 2) AS avg_charge
    FROM telecom_churn
    GROUP BY city
    HAVING COUNT(*) >= 20
)
SELECT 
    city,
    customers,
    monthly_revenue,
    avg_charge,
    RANK() OVER (ORDER BY monthly_revenue DESC) AS revenue_rank
FROM city_revenue
ORDER BY monthly_revenue DESC
LIMIT 15;

-- Query 17: Geographic risk mapping
WITH geo_risk AS (
    SELECT 
        city,
        COUNT(*) AS total,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
        ROUND(AVG(churn_score), 1) AS avg_churn_score
    FROM telecom_churn
    GROUP BY city
    HAVING COUNT(*) >= 15
)
SELECT 
    city,
    total,
    churned,
    ROUND(churned * 100.0 / total, 2) AS churn_rate,
    avg_churn_score,
    CASE 
        WHEN churned * 100.0 / total > 0.35 THEN 'Critical'
        WHEN churned * 100.0 / total > 0.25 THEN 'High'
        WHEN churned * 100.0 / total > 0.15 THEN 'Medium'
        ELSE 'Low'
    END AS risk_level
FROM geo_risk
ORDER BY churn_rate DESC;

-- ============================================================
-- SECTION 5: BUSINESS SEGMENTATION (Queries 18-22)
-- ============================================================

-- Query 18: Customer segmentation matrix
WITH customer_segments AS (
    SELECT 
        customer_id,
        contract,
        tenure_months,
        monthly_charges,
        churn_label,
        CASE 
            WHEN tenure_months <= 12 AND monthly_charges > 70 THEN 'New High-Value'
            WHEN tenure_months <= 12 AND monthly_charges <= 70 THEN 'New Standard'
            WHEN tenure_months BETWEEN 13 AND 36 AND monthly_charges > 70 THEN 'Growing High-Value'
            WHEN tenure_months BETWEEN 13 AND 36 AND monthly_charges <= 70 THEN 'Growing Standard'
            WHEN tenure_months > 36 AND monthly_charges > 70 THEN 'Loyal High-Value'
            ELSE 'Loyal Standard'
        END AS segment
    FROM telecom_churn
)
SELECT 
    segment,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM customer_segments
GROUP BY segment
ORDER BY churn_rate DESC;

-- Query 19: Revenue segmentation
WITH revenue_segments AS (
    SELECT 
        customer_id,
        monthly_charges,
        total_charges,
        churn_label,
        NTILE(4) OVER (ORDER BY monthly_charges) AS charge_quartile
    FROM telecom_churn
)
SELECT 
    CASE charge_quartile
        WHEN 1 THEN 'Q1 (Lowest)'
        WHEN 2 THEN 'Q2'
        WHEN 3 THEN 'Q3'
        WHEN 4 THEN 'Q4 (Highest)'
    END AS revenue_segment,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(total_charges), 2) AS avg_total
FROM revenue_segments
GROUP BY charge_quartile
ORDER BY charge_quartile;

-- Query 20: Risk-segment cross analysis
WITH risk_segments AS (
    SELECT 
        customer_id,
        contract,
        churn_score,
        cltv,
        monthly_charges,
        churn_label,
        CASE 
            WHEN churn_score >= 70 THEN 'High Risk'
            WHEN churn_score >= 40 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk,
        CASE 
            WHEN cltv >= 4000 THEN 'High Value'
            ELSE 'Standard Value'
        END AS value
    FROM telecom_churn
)
SELECT 
    risk,
    value,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(churn_score), 1) AS avg_score
FROM risk_segments
GROUP BY risk, value
ORDER BY risk, value;

-- Query 21: Contract-tenure interaction
WITH contract_tenure AS (
    SELECT 
        contract,
        CASE 
            WHEN tenure_months <= 12 THEN 'Short'
            WHEN tenure_months <= 36 THEN 'Medium'
            ELSE 'Long'
        END AS tenure_length,
        COUNT(*) AS total,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY contract, 
        CASE 
            WHEN tenure_months <= 12 THEN 'Short'
            WHEN tenure_months <= 36 THEN 'Medium'
            ELSE 'Long'
        END
)
SELECT 
    contract,
    tenure_length,
    total,
    churned,
    ROUND(churned * 100.0 / total, 2) AS churn_rate
FROM contract_tenure
ORDER BY contract, tenure_length;

-- Query 22: Service bundle effectiveness
WITH service_bundles AS (
    SELECT 
        customer_id,
        internet_service,
        online_security,
        online_backup,
        tech_support,
        monthly_charges,
        churn_label,
        CASE 
            WHEN online_security = 'Yes' AND tech_support = 'Yes' THEN 'Security+Support'
            WHEN online_security = 'Yes' THEN 'Security Only'
            WHEN tech_support = 'Yes' THEN 'Support Only'
            ELSE 'No Protection'
        END AS protection_bundle
    FROM telecom_churn
    WHERE internet_service != 'No'
)
SELECT 
    protection_bundle,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM service_bundles
GROUP BY protection_bundle
ORDER BY churn_rate DESC;

-- ============================================================
-- SECTION 6: RETENTION ANALYSIS (Queries 23-25)
-- ============================================================

-- Query 23: Retention opportunity identification
WITH retention_candidates AS (
    SELECT 
        customer_id,
        contract,
        tenure_months,
        monthly_charges,
        churn_score,
        cltv,
        churn_label,
        CASE 
            WHEN tenure_months > 24 AND monthly_charges > 70 AND churn_label = 'No' THEN 'High Priority'
            WHEN tenure_months > 12 AND monthly_charges > 50 AND churn_label = 'No' THEN 'Medium Priority'
            ELSE 'Standard'
        END AS retention_priority
    FROM telecom_churn
)
SELECT 
    retention_priority,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(churn_score), 1) AS avg_churn_score,
    ROUND(AVG(cltv), 0) AS avg_cltv,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue
FROM retention_candidates
WHERE retention_priority != 'Standard'
GROUP BY retention_priority
ORDER BY total_monthly_revenue DESC;

-- Query 24: At-risk high-value customers
WITH at_risk AS (
    SELECT 
        customer_id,
        contract,
        monthly_charges,
        total_charges,
        churn_score,
        cltv,
        churn_label
    FROM telecom_churn
    WHERE churn_score >= 60
        AND cltv >= 3000
        AND churn_label = 'No'
)
SELECT 
    customer_id,
    contract,
    monthly_charges,
    total_charges,
    churn_score,
    cltv,
    ROUND(monthly_charges * 12, 2) AS annual_revenue
FROM at_risk
ORDER BY cltv DESC
LIMIT 20;

-- Query 25: Customer lifetime value by segment
WITH cltv_analysis AS (
    SELECT 
        contract,
        internet_service,
        COUNT(*) AS customers,
        ROUND(AVG(cltv), 0) AS avg_cltv,
        ROUND(SUM(cltv), 0) AS total_cltv,
        ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge
    FROM telecom_churn
    GROUP BY contract, internet_service
)
SELECT 
    contract,
    internet_service,
    customers,
    avg_cltv,
    total_cltv,
    avg_monthly_charge,
    RANK() OVER (ORDER BY total_cltv DESC) AS total_cltv_rank
FROM cltv_analysis
ORDER BY total_cltv DESC;
