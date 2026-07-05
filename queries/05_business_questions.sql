-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 05_business_questions.sql
-- Category: Business Analysis (KPIs, Revenue, Segmentation)
-- PostgreSQL 14+ Compatible
-- ============================================================

-- Query 1: Executive summary dashboard
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(total_charges), 2) AS avg_total_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure_months,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(SUM(total_charges), 2) AS total_lifetime_revenue
FROM telecom_churn;

-- Query 2: Revenue at risk from churn
SELECT 
    SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END) AS monthly_revenue_lost,
    SUM(CASE WHEN churn_label = 'Yes' THEN total_charges ELSE 0 END) AS lifetime_revenue_lost,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END) * 100.0 / 
        SUM(monthly_charges), 2
    ) AS pct_monthly_revenue_at_risk
FROM telecom_churn;

-- Query 3: Monthly revenue by contract
SELECT 
    contract,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS monthly_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS revenue_at_risk
FROM telecom_churn
GROUP BY contract
ORDER BY monthly_revenue DESC;

-- Query 4: Churn by contract and internet service
SELECT 
    contract,
    internet_service,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM telecom_churn
GROUP BY contract, internet_service
ORDER BY churn_rate DESC;

-- Query 5: CLTV quintile analysis
WITH cltv_quintiles AS (
    SELECT *, NTILE(5) OVER (ORDER BY cltv) AS quintile
    FROM telecom_churn
)
SELECT 
    quintile,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(cltv), 0) AS avg_cltv
FROM cltv_quintiles
GROUP BY quintile
ORDER BY quintile;

-- Query 6: Revenue by internet service
SELECT 
    internet_service,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS revenue_at_risk
FROM telecom_churn
GROUP BY internet_service
ORDER BY total_monthly_revenue DESC;

-- Query 7: Revenue by payment method
SELECT 
    payment_method,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM telecom_churn
GROUP BY payment_method
ORDER BY total_monthly_revenue DESC;

-- Query 8: Revenue by demographic segment
SELECT 
    gender,
    senior_citizen,
    partner,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_revenue,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM telecom_churn
GROUP BY gender, senior_citizen, partner
HAVING COUNT(*) >= 100
ORDER BY total_revenue DESC;

-- Query 9: Monthly revenue distribution
SELECT 
    CASE 
        WHEN monthly_charges < 30 THEN 'Under $30'
        WHEN monthly_charges < 50 THEN '$30-$50'
        WHEN monthly_charges < 70 THEN '$50-$70'
        WHEN monthly_charges < 90 THEN '$70-$90'
        ELSE '$90+'
    END AS charge_range,
    COUNT(*) AS customers,
    ROUND(SUM(monthly_charges), 2) AS total_revenue,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM telecom_churn
GROUP BY 
    CASE 
        WHEN monthly_charges < 30 THEN 'Under $30'
        WHEN monthly_charges < 50 THEN '$30-$50'
        WHEN monthly_charges < 70 THEN '$50-$70'
        WHEN monthly_charges < 90 THEN '$70-$90'
        ELSE '$90+'
    END
ORDER BY total_revenue DESC;

-- Query 10: Revenue concentration (top 20% of customers)
WITH ranked_revenue AS (
    SELECT 
        customer_id,
        total_charges,
        SUM(total_charges) OVER () AS grand_total,
        ROW_NUMBER() OVER (ORDER BY total_charges DESC) AS rn
    FROM telecom_churn
    WHERE total_charges IS NOT NULL
)
SELECT 
    COUNT(*) AS top_20pct_customers,
    ROUND(SUM(total_charges), 2) AS top_revenue,
    ROUND(SUM(total_charges) / MAX(grand_total) * 100, 2) AS pct_of_total
FROM ranked_revenue
WHERE rn <= (SELECT COUNT(*) * 0.2 FROM telecom_churn WHERE total_charges IS NOT NULL);

-- Query 11: Highest churn cities
SELECT 
    city,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY churn_rate DESC
LIMIT 15;

-- Query 12: Top churn reasons
SELECT 
    churn_reason,
    COUNT(*) AS reason_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure
FROM telecom_churn
WHERE churn_label = 'Yes' AND churn_reason IS NOT NULL
GROUP BY churn_reason
ORDER BY reason_count DESC;

-- Query 13: Churn by tenure bucket
WITH tenure_analysis AS (
    SELECT *,
        CASE 
            WHEN tenure_months <= 6 THEN '0-6 months'
            WHEN tenure_months <= 12 THEN '7-12 months'
            WHEN tenure_months <= 24 THEN '13-24 months'
            WHEN tenure_months <= 36 THEN '25-36 months'
            ELSE '36+ months'
        END AS tenure_bucket
    FROM telecom_churn
)
SELECT 
    tenure_bucket,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM tenure_analysis
GROUP BY tenure_bucket
ORDER BY 
    CASE tenure_bucket
        WHEN '0-6 months' THEN 1
        WHEN '7-12 months' THEN 2
        WHEN '13-24 months' THEN 3
        WHEN '25-36 months' THEN 4
        ELSE 5
    END;

-- Query 14: Churn prediction accuracy
SELECT 
    CASE 
        WHEN churn_score >= 70 THEN 'Predicted High Risk'
        WHEN churn_score >= 40 THEN 'Predicted Medium Risk'
        ELSE 'Predicted Low Risk'
    END AS prediction,
    COUNT(*) AS total,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS actually_churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS actual_churn_rate
FROM telecom_churn
GROUP BY 
    CASE 
        WHEN churn_score >= 70 THEN 'Predicted High Risk'
        WHEN churn_score >= 40 THEN 'Predicted Medium Risk'
        ELSE 'Predicted Low Risk'
    END
ORDER BY actual_churn_rate DESC;

-- Query 15: Customer segmentation matrix
WITH customer_segments AS (
    SELECT *,
        CASE 
            WHEN tenure_months <= 12 AND monthly_charges > 70 THEN 'New High-Value'
            WHEN tenure_months <= 12 AND monthly_charges <= 70 THEN 'New Standard'
            WHEN tenure_months > 36 AND monthly_charges > 70 THEN 'Loyal High-Value'
            WHEN tenure_months > 36 AND monthly_charges <= 70 THEN 'Loyal Standard'
            ELSE 'Established'
        END AS segment
    FROM telecom_churn
)
SELECT 
    segment,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(SUM(monthly_charges), 2) AS total_revenue
FROM customer_segments
GROUP BY segment
ORDER BY churn_rate DESC;

-- Query 16: Risk-segment matrix
WITH risk_segments AS (
    SELECT *,
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
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM risk_segments
GROUP BY risk, value
ORDER BY risk, value;

-- Query 17: Payment behavior analysis
SELECT 
    payment_method,
    paperless_billing,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY payment_method, paperless_billing
ORDER BY churn_rate DESC;

-- Query 18: Geographic insights
WITH geo_insights AS (
    SELECT 
        city,
        state,
        COUNT(*) AS customers,
        ROUND(AVG(monthly_charges), 2) AS avg_charge,
        ROUND(AVG(cltv), 0) AS avg_cltv,
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned
    FROM telecom_churn
    GROUP BY city, state
    HAVING COUNT(*) >= 15
)
SELECT *,
    ROUND(churned * 100.0 / customers, 2) AS churn_rate,
    RANK() OVER (ORDER BY avg_cltv DESC) AS cltv_rank
FROM geo_insights
ORDER BY avg_cltv DESC
LIMIT 20;

-- Query 19: Senior citizen deep dive
SELECT 
    senior_citizen,
    gender,
    contract,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY senior_citizen, gender, contract
HAVING COUNT(*) >= 50
ORDER BY churn_rate DESC;

-- Query 20: High-value customers at risk
SELECT 
    customer_id,
    contract,
    tenure_months,
    monthly_charges,
    total_charges,
    cltv,
    churn_score
FROM telecom_churn
WHERE cltv >= 4000
    AND churn_score >= 60
    AND churn_label = 'No'
ORDER BY cltv DESC
LIMIT 20;

-- Query 21: Contract conversion opportunity
SELECT 
    contract,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(cltv), 0) AS avg_cltv,
    ROUND(SUM(monthly_charges), 2) AS total_revenue,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
WHERE churn_label = 'No'
GROUP BY contract
ORDER BY churn_rate DESC;

-- Query 22: Service bundle impact
SELECT 
    internet_service,
    CASE WHEN online_security = 'Yes' THEN 'Yes' ELSE 'No' END AS has_security,
    CASE WHEN tech_support = 'Yes' THEN 'Yes' ELSE 'No' END AS has_support,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_charge
FROM telecom_churn
WHERE internet_service != 'No'
GROUP BY internet_service, 
    CASE WHEN online_security = 'Yes' THEN 'Yes' ELSE 'No' END,
    CASE WHEN tech_support = 'Yes' THEN 'Yes' ELSE 'No' END
ORDER BY churn_rate DESC;

-- Query 23: Retention ROI analysis
SELECT 
    contract,
    COUNT(*) AS total_customers,
    ROUND(AVG(cltv), 0) AS avg_cltv,
    ROUND(SUM(cltv), 0) AS total_cltv,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN cltv ELSE 0 END), 0) AS cltv_lost
FROM telecom_churn
GROUP BY contract
ORDER BY cltv_lost DESC;

-- Query 24: Electronic check risk profile
SELECT 
    payment_method,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    ROUND(AVG(churn_score), 1) AS avg_churn_score,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY payment_method
ORDER BY churn_rate DESC;

-- Query 25: Comprehensive business KPIs
SELECT 
    'Total Customers' AS metric, COUNT(*)::text AS value FROM telecom_churn
UNION ALL
SELECT 'Churn Rate', ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)::text FROM telecom_churn
UNION ALL
SELECT 'Avg Monthly Charge', ROUND(AVG(monthly_charges), 2)::text FROM telecom_churn
UNION ALL
SELECT 'Total Monthly Revenue', ROUND(SUM(monthly_charges), 2)::text FROM telecom_churn
UNION ALL
SELECT 'Revenue at Risk', ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2)::text FROM telecom_churn
UNION ALL
SELECT 'Avg Tenure (months)', ROUND(AVG(tenure_months), 1)::text FROM telecom_churn
UNION ALL
SELECT 'Avg CLTV', ROUND(AVG(cltv), 0)::text FROM telecom_churn;
