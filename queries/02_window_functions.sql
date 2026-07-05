-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 02_window_functions.sql
-- Category: Window Functions (Ranking, Analytics, Frames)
-- PostgreSQL 14+ Compatible
-- ============================================================
-- This file contains 30 window function queries covering
-- ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE,
-- aggregate windows, and frame specifications.
-- ============================================================

-- ============================================================
-- SECTION 1: RANKING FUNCTIONS (Queries 1-8)
-- ============================================================

-- Query 1: Compare ROW_NUMBER, RANK, and DENSE_RANK
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROW_NUMBER() OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS row_num,
    RANK()       OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS rank_num,
    DENSE_RANK() OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS dense_rank_num
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;

-- Query 2: Top 5 highest-paying customers per contract type
SELECT *
FROM (
    SELECT 
        customer_id,
        contract,
        monthly_charges,
        total_charges,
        churn_label,
        ROW_NUMBER() OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS rn
    FROM telecom_churn
) ranked
WHERE rn <= 5
ORDER BY contract, rn;

-- Query 3: Rank customers by CLTV within each contract
SELECT 
    customer_id,
    contract,
    cltv,
    monthly_charges,
    churn_label,
    RANK() OVER (PARTITION BY contract ORDER BY cltv DESC) AS cltv_rank
FROM telecom_churn
ORDER BY contract, cltv DESC;

-- Query 4: Percent rank of customers by monthly charges
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROUND(
        PERCENT_RANK() OVER (PARTITION BY contract ORDER BY monthly_charges)::numeric, 4
    ) AS percentile,
    NTILE(4) OVER (PARTITION BY contract ORDER BY monthly_charges) AS quartile
FROM telecom_churn
ORDER BY contract, monthly_charges;

-- Query 5: Rank by churn score with risk categories
SELECT 
    customer_id,
    contract,
    churn_score,
    monthly_charges,
    DENSE_RANK() OVER (ORDER BY churn_score DESC) AS churn_rank,
    CASE 
        WHEN DENSE_RANK() OVER (ORDER BY churn_score DESC) <= 100 THEN 'Critical'
        WHEN DENSE_RANK() OVER (ORDER BY churn_score DESC) <= 500 THEN 'High'
        WHEN DENSE_RANK() OVER (ORDER BY churn_score DESC) <= 1500 THEN 'Medium'
        ELSE 'Low'
    END AS risk_category
FROM telecom_churn
ORDER BY churn_score DESC;

-- Query 6: Rank customers by total charges within internet service
SELECT 
    customer_id,
    internet_service,
    total_charges,
    monthly_charges,
    ROW_NUMBER() OVER (PARTITION BY internet_service ORDER BY total_charges DESC) AS rn,
    RANK() OVER (PARTITION BY internet_service ORDER BY total_charges DESC) AS rnk
FROM telecom_churn
ORDER BY internet_service, total_charges DESC;

-- Query 7: Rank churned customers by CLTV
SELECT 
    customer_id,
    contract,
    cltv,
    churn_score,
    monthly_charges,
    ROW_NUMBER() OVER (PARTITION BY contract ORDER BY cltv DESC) AS cltv_rank
FROM telecom_churn
WHERE churn_label = 'Yes'
ORDER BY contract, cltv DESC;

-- Query 8: Dense rank by city for monthly charges
SELECT 
    customer_id,
    city,
    monthly_charges,
    DENSE_RANK() OVER (PARTITION BY city ORDER BY monthly_charges DESC) AS city_rank,
    COUNT(*) OVER (PARTITION BY city) AS customers_in_city
FROM telecom_churn
ORDER BY city, monthly_charges DESC;

-- ============================================================
-- SECTION 2: AGGREGATE WINDOWS (Queries 9-14)
-- ============================================================

-- Query 9: Customer charges vs contract average
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROUND(AVG(monthly_charges) OVER (PARTITION BY contract), 2) AS avg_by_contract,
    ROUND(
        monthly_charges - AVG(monthly_charges) OVER (PARTITION BY contract), 2
    ) AS diff_from_avg,
    ROUND(
        (monthly_charges - AVG(monthly_charges) OVER (PARTITION BY contract)) /
        NULLIF(AVG(monthly_charges) OVER (PARTITION BY contract), 0) * 100, 2
    ) AS pct_diff_from_avg
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;

-- Query 10: Running count of churned customers by contract
SELECT 
    customer_id,
    contract,
    churn_label,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) OVER (
        PARTITION BY contract ORDER BY customer_id
    ) AS running_churn_count,
    COUNT(*) OVER (PARTITION BY contract) AS total_in_contract
FROM telecom_churn
ORDER BY contract, customer_id;

-- Query 11: Min and max charges within each contract
SELECT 
    customer_id,
    contract,
    monthly_charges,
    MIN(monthly_charges) OVER (PARTITION BY contract) AS min_in_contract,
    MAX(monthly_charges) OVER (PARTITION BY contract) AS max_in_contract,
    ROUND(
        (monthly_charges - MIN(monthly_charges) OVER (PARTITION BY contract)) /
        NULLIF(MAX(monthly_charges) OVER (PARTITION BY contract) - MIN(monthly_charges) OVER (PARTITION BY contract), 0) * 100, 2
    ) AS range_position_pct
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;

-- Query 12: Cumulative distribution of monthly charges
SELECT 
    customer_id,
    monthly_charges,
    ROUND(CUME_DIST() OVER (ORDER BY monthly_charges)::numeric, 4) AS cumulative_distribution,
    ROUND(PERCENT_RANK() OVER (ORDER BY monthly_charges)::numeric, 4) AS percentile_rank
FROM telecom_churn
ORDER BY monthly_charges;

-- Query 13: Running total of charges by contract
SELECT 
    customer_id,
    contract,
    monthly_charges,
    SUM(monthly_charges) OVER (
        PARTITION BY contract ORDER BY customer_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM telecom_churn
ORDER BY contract, customer_id;

-- Query 14: Average charges by contract with running average
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROUND(AVG(monthly_charges) OVER (
        PARTITION BY contract 
        ORDER BY customer_id 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS running_avg
FROM telecom_churn
ORDER BY contract, customer_id;

-- ============================================================
-- SECTION 3: LAG/LEAD FUNCTIONS (Queries 15-18)
-- ============================================================

-- Query 15: Compare to previous and next customer in same contract
SELECT 
    customer_id,
    contract,
    monthly_charges,
    LAG(monthly_charges)  OVER (PARTITION BY contract ORDER BY monthly_charges) AS prev_charge,
    LEAD(monthly_charges) OVER (PARTITION BY contract ORDER BY monthly_charges) AS next_charge,
    ROUND(
        monthly_charges - LAG(monthly_charges) OVER (PARTITION BY contract ORDER BY monthly_charges), 2
    ) AS diff_from_prev
FROM telecom_churn
ORDER BY contract, monthly_charges;

-- Query 16: Rank difference between consecutive customers
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROW_NUMBER() OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS current_rank,
    LAG(ROW_NUMBER() OVER (PARTITION BY contract ORDER BY monthly_charges DESC)) 
        OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS prev_rank,
    ROW_NUMBER() OVER (PARTITION BY contract ORDER BY monthly_charges DESC) -
    LAG(ROW_NUMBER() OVER (PARTITION BY contract ORDER BY monthly_charges DESC)) 
        OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS rank_change
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;

-- Query 17: Month-over-month comparison (simulated with tenure)
SELECT 
    customer_id,
    contract,
    tenure_months,
    monthly_charges,
    LAG(monthly_charges, 1) OVER (PARTITION BY contract ORDER BY tenure_months) AS prev_tenure_charge,
    monthly_charges - LAG(monthly_charges, 1) OVER (PARTITION BY contract ORDER BY tenure_months) AS charge_change
FROM telecom_churn
WHERE contract = 'Month-to-month'
ORDER BY tenure_months, monthly_charges;

-- Query 18: First and last values in each partition
SELECT 
    customer_id,
    contract,
    monthly_charges,
    FIRST_VALUE(customer_id) OVER (
        PARTITION BY contract ORDER BY monthly_charges DESC
    ) AS highest_paying_id,
    LAST_VALUE(customer_id) OVER (
        PARTITION BY contract ORDER BY monthly_charges DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_paying_id
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;

-- ============================================================
-- SECTION 4: NTILE & DISTRIBUTION (Queries 19-22)
-- ============================================================

-- Query 19: Quartiles by monthly charges
SELECT 
    customer_id,
    monthly_charges,
    NTILE(4) OVER (ORDER BY monthly_charges) AS quartile,
    CASE NTILE(4) OVER (ORDER BY monthly_charges)
        WHEN 1 THEN 'Bottom 25%'
        WHEN 2 THEN '25-50%'
        WHEN 3 THEN '50-75%'
        WHEN 4 THEN 'Top 25%'
    END AS quartile_label
FROM telecom_churn
ORDER BY monthly_charges;

-- Query 20: Deciles by CLTV
SELECT 
    customer_id,
    cltv,
    NTILE(10) OVER (ORDER BY cltv) AS decile,
    ROUND(PERCENT_RANK() OVER (ORDER BY cltv)::numeric, 4) AS percentile
FROM telecom_churn
ORDER BY cltv;

-- Query 21: Quintiles by churn score
SELECT 
    customer_id,
    churn_score,
    NTILE(5) OVER (ORDER BY churn_score DESC) AS risk_quintile,
    CASE 
        WHEN NTILE(5) OVER (ORDER BY churn_score DESC) = 1 THEN 'Highest Risk'
        WHEN NTILE(5) OVER (ORDER BY churn_score DESC) = 2 THEN 'High Risk'
        WHEN NTILE(5) OVER (ORDER BY churn_score DESC) = 3 THEN 'Medium Risk'
        WHEN NTILE(5) OVER (ORDER BY churn_score DESC) = 4 THEN 'Low Risk'
        ELSE 'Lowest Risk'
    END AS risk_tier
FROM telecom_churn
ORDER BY churn_score DESC;

-- Query 22: Percentile by total charges within contract
SELECT 
    customer_id,
    contract,
    total_charges,
    ROUND(PERCENT_RANK() OVER (PARTITION BY contract ORDER BY total_charges)::numeric, 4) AS percentile_in_contract,
    NTILE(5) OVER (PARTITION BY contract ORDER BY total_charges) AS quintile_in_contract
FROM telecom_churn
ORDER BY contract, total_charges DESC;

-- ============================================================
-- SECTION 5: MOVING AVERAGES & FRAMES (Queries 23-26)
-- ============================================================

-- Query 23: Moving average of monthly charges (window of 5)
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROUND(AVG(monthly_charges) OVER (
        ORDER BY monthly_charges 
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ), 2) AS moving_avg_5
FROM telecom_churn
ORDER BY monthly_charges;

-- Query 24: Moving average with frame clause
SELECT 
    customer_id,
    contract,
    monthly_charges,
    ROUND(AVG(monthly_charges) OVER (
        PARTITION BY contract 
        ORDER BY monthly_charges 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS trailing_avg_5
FROM telecom_churn
ORDER BY contract, monthly_charges;

-- Query 25: Cumulative percentage of revenue
SELECT 
    customer_id,
    total_charges,
    SUM(total_charges) OVER (ORDER BY total_charges DESC) AS running_revenue,
    ROUND(
        SUM(total_charges) OVER (ORDER BY total_charges DESC) * 100.0 / 
        SUM(total_charges) OVER (), 2
    ) AS cumulative_pct
FROM telecom_churn
WHERE total_charges IS NOT NULL
ORDER BY total_charges DESC;

-- Query 26: Running sum with RANGE frame
SELECT 
    customer_id,
    monthly_charges,
    SUM(monthly_charges) OVER (
        ORDER BY monthly_charges
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum
FROM telecom_churn
ORDER BY monthly_charges;

-- ============================================================
-- SECTION 6: MULTI-PARTITION & ADVANCED (Queries 27-30)
-- ============================================================

-- Query 27: Multiple partition analysis
SELECT 
    customer_id,
    contract,
    internet_service,
    monthly_charges,
    RANK() OVER (PARTITION BY contract, internet_service ORDER BY monthly_charges DESC) AS rank_in_group,
    COUNT(*) OVER (PARTITION BY contract, internet_service) AS group_size
FROM telecom_churn
ORDER BY contract, internet_service, monthly_charges DESC;

-- Query 28: Window function with CASE in partition
SELECT 
    customer_id,
    contract,
    monthly_charges,
    SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END) OVER (
        PARTITION BY contract ORDER BY monthly_charges DESC
    ) AS cumulative_churn_revenue
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;

-- Query 29: Row-to-row comparison with LAG and LEAD
SELECT 
    customer_id,
    contract,
    monthly_charges,
    LAG(monthly_charges, 1, 0)  OVER (PARTITION BY contract ORDER BY monthly_charges) AS prev_charge,
    LEAD(monthly_charges, 1, 0) OVER (PARTITION BY contract ORDER BY monthly_charges) AS next_charge,
    CASE 
        WHEN monthly_charges > LAG(monthly_charges) OVER (PARTITION BY contract ORDER BY monthly_charges) THEN 'Increase'
        WHEN monthly_charges < LAG(monthly_charges) OVER (PARTITION BY contract ORDER BY monthly_charges) THEN 'Decrease'
        ELSE 'Same'
    END AS direction
FROM telecom_churn
ORDER BY contract, monthly_charges;

-- Query 30: Comprehensive window function dashboard
SELECT 
    customer_id,
    contract,
    internet_service,
    monthly_charges,
    total_charges,
    churn_label,
    -- Rankings
    ROW_NUMBER() OVER (ORDER BY monthly_charges DESC) AS overall_rank,
    RANK() OVER (PARTITION BY contract ORDER BY monthly_charges DESC) AS contract_rank,
    -- Aggregates
    ROUND(AVG(monthly_charges) OVER (PARTITION BY contract), 2) AS contract_avg,
    MIN(monthly_charges) OVER (PARTITION BY contract) AS contract_min,
    MAX(monthly_charges) OVER (PARTITION BY contract) AS contract_max,
    -- Distribution
    NTILE(4) OVER (ORDER BY monthly_charges) AS charge_quartile,
    -- LAG/LEAD
    LAG(monthly_charges) OVER (PARTITION BY contract ORDER BY monthly_charges) AS prev_in_contract
FROM telecom_churn
ORDER BY contract, monthly_charges DESC;
