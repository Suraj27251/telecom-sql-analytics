{{ config(materialized='table') }}

SELECT
    COUNT(*) AS total_customers,

    SUM(churn_flag) AS churned_customers,

    COUNT(*) - SUM(churn_flag) AS active_customers,

    ROUND(
        100.0 * SUM(churn_flag) / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,

    ROUND(SUM(total_charges), 2) AS total_revenue,

    ROUND(AVG(cltv), 2) AS avg_cltv

FROM {{ ref('int_customer_metrics') }}