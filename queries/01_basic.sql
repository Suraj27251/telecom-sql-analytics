-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 01_basic.sql
-- Category: Basic Queries (Aggregations, GROUP BY, Filtering)
-- PostgreSQL 14+ Compatible
-- ============================================================
-- This file contains 30 foundational SQL queries covering
-- aggregate functions, GROUP BY, CASE expressions, and
-- basic filtering patterns used in data analytics.
-- ============================================================

-- ============================================================
-- SECTION 1: OVERVIEW METRICS (Queries 1-5)
-- ============================================================

-- Query 1: Total customer count
SELECT COUNT(*) AS total_customers
FROM telecom_churn;

-- Query 2: Overall churn rate
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    SUM(CASE WHEN churn_label = 'No' THEN 1 ELSE 0 END) AS active,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn;

-- Query 3: Monthly revenue summary
SELECT 
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(MIN(monthly_charges), 2) AS min_monthly_charge,
    ROUND(MAX(monthly_charges), 2) AS max_monthly_charge,
    ROUND(STDDEV(monthly_charges), 2) AS stddev_monthly_charge
FROM telecom_churn;

-- Query 4: Lifetime revenue summary
SELECT 
    ROUND(SUM(total_charges), 2) AS total_lifetime_revenue,
    ROUND(AVG(total_charges), 2) AS avg_lifetime_charge,
    ROUND(MIN(total_charges), 2) AS min_lifetime_charge,
    ROUND(MAX(total_charges), 2) AS max_lifetime_charge
FROM telecom_churn
WHERE total_charges IS NOT NULL;

-- Query 5: Tenure distribution overview
SELECT 
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    MIN(tenure_months) AS min_tenure,
    MAX(tenure_months) AS max_tenure,
    ROUND(STDDEV(tenure_months), 1) AS stddev_tenure
FROM telecom_churn;

-- ============================================================
-- SECTION 2: DEMOGRAPHIC ANALYSIS (Queries 6-10)
-- ============================================================

-- Query 6: Customers by gender
SELECT 
    gender,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM telecom_churn), 2) AS pct
FROM telecom_churn
GROUP BY gender
ORDER BY customer_count DESC;

-- Query 7: Churn rate by gender
SELECT 
    gender,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY gender;

-- Query 8: Senior citizen breakdown
SELECT 
    senior_citizen,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge
FROM telecom_churn
GROUP BY senior_citizen;

-- Query 9: Partner and dependent combinations
SELECT 
    partner,
    dependents,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY partner, dependents
ORDER BY churn_rate_pct DESC;

-- Query 10: Full demographic profile
SELECT 
    gender,
    senior_citizen,
    partner,
    dependents,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure
FROM telecom_churn
GROUP BY gender, senior_citizen, partner, dependents
HAVING COUNT(*) >= 50
ORDER BY churn_rate_pct DESC;

-- ============================================================
-- SECTION 3: CONTRACT ANALYSIS (Queries 11-15)
-- ============================================================

-- Query 11: Customer distribution by contract
SELECT 
    contract,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM telecom_churn), 2) AS pct
FROM telecom_churn
GROUP BY contract
ORDER BY customer_count DESC;

-- Query 12: Churn rate by contract type
SELECT 
    contract,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure
FROM telecom_churn
GROUP BY contract
ORDER BY churn_rate_pct DESC;

-- Query 13: Contract type with revenue breakdown
SELECT 
    contract,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(SUM(total_charges), 2) AS total_lifetime_revenue
FROM telecom_churn
GROUP BY contract
ORDER BY total_monthly_revenue DESC;

-- Query 14: Paperless billing impact
SELECT 
    paperless_billing,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM telecom_churn
GROUP BY paperless_billing;

-- Query 15: Contract and paperless billing cross-analysis
SELECT 
    contract,
    paperless_billing,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY contract, paperless_billing
ORDER BY contract, churn_rate_pct DESC;

-- ============================================================
-- SECTION 4: SERVICE ANALYSIS (Queries 16-20)
-- ============================================================

-- Query 16: Internet service distribution
SELECT 
    internet_service,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM telecom_churn
GROUP BY internet_service
ORDER BY churn_rate_pct DESC;

-- Query 17: Phone service and multiple lines analysis
SELECT 
    phone_service,
    multiple_lines,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY phone_service, multiple_lines
ORDER BY churn_rate_pct DESC;

-- Query 18: Online security impact on churn
SELECT 
    online_security,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY online_security;

-- Query 19: Tech support impact on churn
SELECT 
    tech_support,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY tech_support;

-- Query 20: Streaming services analysis
SELECT 
    streaming_tv,
    streaming_movies,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM telecom_churn
GROUP BY streaming_tv, streaming_movies
ORDER BY churn_rate_pct DESC;

-- ============================================================
-- SECTION 5: PAYMENT ANALYSIS (Queries 21-25)
-- ============================================================

-- Query 21: Payment method distribution
SELECT 
    payment_method,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM telecom_churn), 2) AS pct
FROM telecom_churn
GROUP BY payment_method
ORDER BY total DESC;

-- Query 22: Churn rate by payment method
SELECT 
    payment_method,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure
FROM telecom_churn
GROUP BY payment_method
ORDER BY churn_rate_pct DESC;

-- Query 23: Payment method revenue comparison
SELECT 
    payment_method,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(SUM(total_charges), 2) AS total_lifetime_revenue,
    ROUND(SUM(total_charges) / COUNT(*), 2) AS avg_lifetime_revenue
FROM telecom_churn
GROUP BY payment_method
ORDER BY total_monthly_revenue DESC;

-- Query 24: Electronic check risk analysis
SELECT 
    payment_method,
    senior_citizen,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
WHERE payment_method = 'Electronic check'
GROUP BY payment_method, senior_citizen;

-- Query 25: Auto-pay vs manual payment comparison
SELECT 
    CASE 
        WHEN payment_method IN ('Electronic check', 'Mailed check') THEN 'Manual Payment'
        ELSE 'Auto Payment'
    END AS payment_type,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM telecom_churn
GROUP BY 
    CASE 
        WHEN payment_method IN ('Electronic check', 'Mailed check') THEN 'Manual Payment'
        ELSE 'Auto Payment'
    END;

-- ============================================================
-- SECTION 6: CHARGE DISTRIBUTION (Queries 26-30)
-- ============================================================

-- Query 26: Monthly charges by tenure bucket
SELECT 
    CASE 
        WHEN tenure_months <= 12 THEN '0-12 months'
        WHEN tenure_months <= 24 THEN '13-24 months'
        WHEN tenure_months <= 36 THEN '25-36 months'
        WHEN tenure_months <= 48 THEN '37-48 months'
        WHEN tenure_months <= 60 THEN '49-60 months'
        ELSE '60+ months'
    END AS tenure_bucket,
    COUNT(*) AS total,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(total_charges), 2) AS avg_total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM telecom_churn
GROUP BY 
    CASE 
        WHEN tenure_months <= 12 THEN '0-12 months'
        WHEN tenure_months <= 24 THEN '13-24 months'
        WHEN tenure_months <= 36 THEN '25-36 months'
        WHEN tenure_months <= 48 THEN '37-48 months'
        WHEN tenure_months <= 60 THEN '49-60 months'
        ELSE '60+ months'
    END
ORDER BY 
    CASE 
        WHEN tenure_months <= 12 THEN 1
        WHEN tenure_months <= 24 THEN 2
        WHEN tenure_months <= 36 THEN 3
        WHEN tenure_months <= 48 THEN 4
        WHEN tenure_months <= 60 THEN 5
        ELSE 6
    END;

-- Query 27: Charge tier analysis
SELECT 
    CASE 
        WHEN monthly_charges < 30 THEN 'Low (<$30)'
        WHEN monthly_charges < 50 THEN 'Medium-Low ($30-$50)'
        WHEN monthly_charges < 70 THEN 'Medium ($50-$70)'
        WHEN monthly_charges < 90 THEN 'Medium-High ($70-$90)'
        ELSE 'High ($90+)'
    END AS charge_tier,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(tenure_months), 1) AS avg_tenure
FROM telecom_churn
GROUP BY 
    CASE 
        WHEN monthly_charges < 30 THEN 'Low (<$30)'
        WHEN monthly_charges < 50 THEN 'Medium-Low ($30-$50)'
        WHEN monthly_charges < 70 THEN 'Medium ($50-$70)'
        WHEN monthly_charges < 90 THEN 'Medium-High ($70-$90)'
        ELSE 'High ($90+)'
    END
ORDER BY avg_tenure;

-- Query 28: CLTV distribution by contract
SELECT 
    contract,
    COUNT(*) AS total,
    ROUND(AVG(cltv), 0) AS avg_cltv,
    MIN(cltv) AS min_cltv,
    MAX(cltv) AS max_cltv,
    SUM(CASE WHEN cltv >= 5000 THEN 1 ELSE 0 END) AS platinum_count,
    SUM(CASE WHEN cltv < 2000 THEN 1 ELSE 0 END) AS basic_count
FROM telecom_churn
GROUP BY contract
ORDER BY avg_cltv DESC;

-- Query 29: Churn score distribution
SELECT 
    CASE 
        WHEN churn_score >= 80 THEN 'Very High (80-100)'
        WHEN churn_score >= 60 THEN 'High (60-79)'
        WHEN churn_score >= 40 THEN 'Medium (40-59)'
        WHEN churn_score >= 20 THEN 'Low (20-39)'
        ELSE 'Very Low (0-19)'
    END AS score_bucket,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS actual_churned,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS actual_churn_rate
FROM telecom_churn
GROUP BY 
    CASE 
        WHEN churn_score >= 80 THEN 'Very High (80-100)'
        WHEN churn_score >= 60 THEN 'High (60-79)'
        WHEN churn_score >= 40 THEN 'Medium (40-59)'
        WHEN churn_score >= 20 THEN 'Low (20-39)'
        ELSE 'Very Low (0-19)'
    END
ORDER BY actual_churn_rate DESC;

-- Query 30: Top 10 highest-paying customers
SELECT 
    customer_id,
    gender,
    senior_citizen,
    contract,
    internet_service,
    payment_method,
    monthly_charges,
    total_charges,
    tenure_months,
    churn_label
FROM telecom_churn
ORDER BY monthly_charges DESC
LIMIT 10;
