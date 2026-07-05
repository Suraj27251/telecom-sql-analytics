-- ============================================================
-- Telecom SQL Analytics Platform
-- File: 06_views.sql
-- Category: Views and Materialized Views
-- PostgreSQL 14+ Compatible
-- ============================================================

-- VIEW 1: Customer Summary
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT 
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure_months,
    phone_service,
    internet_service,
    contract,
    monthly_charges,
    total_charges,
    churn_label,
    churn_score,
    cltv,
    CASE 
        WHEN tenure_months <= 12 THEN 'New'
        WHEN tenure_months <= 36 THEN 'Established'
        WHEN tenure_months <= 60 THEN 'Loyal'
        ELSE 'Veteran'
    END AS tenure_segment,
    CASE 
        WHEN churn_score >= 70 THEN 'High Risk'
        WHEN churn_score >= 40 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level,
    CASE 
        WHEN cltv >= 5000 THEN 'Platinum'
        WHEN cltv >= 4000 THEN 'Gold'
        WHEN cltv >= 3000 THEN 'Silver'
        WHEN cltv >= 2000 THEN 'Bronze'
        ELSE 'Basic'
    END AS value_tier
FROM telecom_churn;

-- VIEW 2: Churn Analysis
CREATE OR REPLACE VIEW vw_churn_analysis AS
SELECT 
    customer_id,
    contract,
    internet_service,
    payment_method,
    monthly_charges,
    total_charges,
    tenure_months,
    churn_label,
    churn_score,
    churn_reason,
    CASE WHEN churn_label = 'Yes' THEN 'Churned' ELSE 'Active' END AS status,
    CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END AS revenue_at_risk
FROM telecom_churn;

-- VIEW 3: Revenue Summary
CREATE OR REPLACE VIEW vw_revenue_summary AS
SELECT 
    contract,
    internet_service,
    COUNT(*) AS customer_count,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(SUM(total_charges), 2) AS total_lifetime_revenue,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS monthly_revenue_at_risk
FROM telecom_churn
GROUP BY contract, internet_service;

-- VIEW 4: Service Adoption
CREATE OR REPLACE VIEW vw_service_adoption AS
SELECT 
    customer_id,
    phone_service,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    (
        CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END
    ) AS total_add_ons,
    monthly_charges,
    churn_label
FROM telecom_churn;

-- VIEW 5: Geographic Performance
CREATE OR REPLACE VIEW vw_geographic_performance AS
SELECT 
    city,
    state,
    COUNT(*) AS customer_count,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(total_charges), 2) AS avg_total_charges,
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(cltv), 0) AS avg_cltv
FROM telecom_churn
GROUP BY city, state
HAVING COUNT(*) >= 10;

-- VIEW 6: Risk Scores
CREATE OR REPLACE VIEW vw_risk_scores AS
SELECT 
    customer_id,
    contract,
    internet_service,
    monthly_charges,
    churn_score,
    cltv,
    CASE 
        WHEN churn_score >= 70 THEN 'Critical'
        WHEN churn_score >= 50 THEN 'High'
        WHEN churn_score >= 30 THEN 'Medium'
        ELSE 'Low'
    END AS risk_category,
    RANK() OVER (ORDER BY churn_score DESC) AS risk_rank
FROM telecom_churn
WHERE churn_label = 'No';

-- VIEW 7: Contract Performance
CREATE OR REPLACE VIEW vw_contract_performance AS
SELECT 
    contract,
    COUNT(*) AS total_customers,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    ROUND(AVG(total_charges), 2) AS avg_total_charges,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS revenue_at_risk
FROM telecom_churn
GROUP BY contract;

-- VIEW 8: Demographic Insights
CREATE OR REPLACE VIEW vw_demographic_insights AS
SELECT 
    gender,
    senior_citizen,
    partner,
    dependents,
    COUNT(*) AS customer_count,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    ROUND(AVG(total_charges), 2) AS avg_total_charges,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY gender, senior_citizen, partner, dependents;

-- VIEW 9: Payment Analysis
CREATE OR REPLACE VIEW vw_payment_analysis AS
SELECT 
    payment_method,
    COUNT(*) AS customer_count,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(AVG(tenure_months), 1) AS avg_tenure,
    ROUND(AVG(total_charges), 2) AS avg_total_charges,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn
GROUP BY payment_method;

-- VIEW 10: Executive Dashboard
CREATE OR REPLACE VIEW vw_executive_dashboard AS
SELECT 
    'Overall' AS metric_category,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(SUM(monthly_charges), 2) AS total_monthly_revenue,
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN monthly_charges ELSE 0 END), 2) AS revenue_at_risk
FROM telecom_churn;

-- ============================================================
-- MATERIALIZED VIEWS
-- ============================================================

-- Materialized View 1: Churn summary by contract and internet
DROP MATERIALIZED VIEW IF EXISTS mv_churn_summary;
CREATE MATERIALIZED VIEW mv_churn_summary AS
SELECT 
    contract,
    internet_service,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(SUM(monthly_charges), 2) AS total_revenue
FROM telecom_churn
GROUP BY contract, internet_service;

-- Materialized View 2: City-level metrics
DROP MATERIALIZED VIEW IF EXISTS mv_city_metrics;
CREATE MATERIALIZED VIEW mv_city_metrics AS
SELECT 
    city,
    state,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_charges), 2) AS avg_charge,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(AVG(cltv), 0) AS avg_cltv
FROM telecom_churn
GROUP BY city, state
HAVING COUNT(*) >= 10;

-- Refresh materialized views (run periodically)
-- REFRESH MATERIALIZED VIEW mv_churn_summary;
-- REFRESH MATERIALIZED VIEW mv_city_metrics;
