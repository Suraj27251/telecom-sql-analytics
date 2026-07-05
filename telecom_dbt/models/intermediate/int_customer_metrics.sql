{{ config(materialized='view') }}

SELECT
    customer_id,
    city,
    state,
    gender,
    contract,
    internet_service,
    monthly_charges,
    total_charges,
    tenure_months,
    cltv,
    churn_label,

    CASE
        WHEN tenure_months < 12 THEN 'New'
        WHEN tenure_months BETWEEN 12 AND 24 THEN 'Growing'
        WHEN tenure_months BETWEEN 25 AND 48 THEN 'Loyal'
        ELSE 'Long-term'
    END AS customer_segment,

    CASE
        WHEN monthly_charges < 40 THEN 'Low'
        WHEN monthly_charges < 80 THEN 'Medium'
        ELSE 'High'
    END AS spending_category,

    CASE
        WHEN churn_label = 'Yes' THEN 1
        ELSE 0
    END AS churn_flag

FROM {{ ref('stg_telecom_churn') }}