# Project Report: Telecom SQL Analytics Platform

## Executive Summary

This project demonstrates production-quality SQL analytics using PostgreSQL and the IBM Telco Customer Churn dataset. The analysis covers 7,043 customers across 33 data points, providing actionable business insights for customer retention and revenue optimization.

## Business Context

Customer churn is a critical metric for telecom companies. Acquiring a new customer costs 5-25x more than retaining an existing one. This analysis identifies churn patterns, at-risk segments, and revenue impact to support data-driven retention strategies.

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Customers | 7,043 |
| Churned Customers | 1,869 |
| Churn Rate | 26.54% |
| Monthly Revenue | $456,296 |
| Revenue at Risk | $139,096 |
| Avg Monthly Charge | $64.76 |
| Avg Total Charges | $2,283 |
| Avg Tenure | 32.37 months |

## Business Insights

### 1. Contract Type is the Strongest Churn Predictor

| Contract | Churn Rate | Customers |
|----------|------------|-----------|
| Month-to-month | 42.71% | 3,875 |
| One year | 11.27% | 1,695 |
| Two year | 2.83% | 1,473 |

**Recommendation:** Incentivize month-to-month customers to upgrade to annual contracts.

### 2. Fiber Optic Has Highest Churn

| Internet Service | Churn Rate |
|------------------|------------|
| Fiber optic | 41.89% |
| DSL | 18.96% |
| No internet | 7.40% |

**Recommendation:** Investigate fiber optic service quality and pricing.

### 3. Electronic Check Users Churn More

| Payment Method | Churn Rate |
|----------------|------------|
| Electronic check | 45.29% |
| Mailed check | 33.43% |
| Bank transfer | 32.88% |
| Credit card | 31.39% |

**Recommendation:** Promote automatic payment methods.

### 4. New Customers Are Highest Risk

| Tenure | Churn Rate |
|--------|------------|
| 0-6 months | 44.39% |
| 7-12 months | 32.87% |
| 13-24 months | 21.89% |
| 25-36 months | 14.34% |
| 37+ months | 7.45% |

**Recommendation:** Implement 90-day onboarding program.

### 5. Revenue at Risk

- **Monthly revenue from churned customers:** $139,096
- **Percentage of total revenue:** 30.48%
- **Annual impact:** ~$1.67M

## Technical Implementation

### SQL Techniques Used

| Technique | Count | Purpose |
|-----------|-------|---------|
| Basic Aggregations | 30 | Foundation metrics |
| Window Functions | 30 | Rankings, running totals |
| Subqueries | 25 | Segment comparisons |
| CTEs | 25 | Complex transformations |
| Views | 12 | Reusable reporting |
| Indexes | 10 | Performance optimization |
| Stored Procedures | 12 | Automation, functions |
| Advanced Analytics | 20 | Pivoting, complex analysis |

### Performance Optimizations

1. **Created 10 indexes** for common query patterns
2. **Used EXPLAIN ANALYZE** to verify query plans
3. **Implemented materialized views** for expensive aggregations
4. **Rewrote correlated subqueries** as window functions

### Database Objects

- 1 main table with CHECK constraints and comments
- 10 standard views for reporting
- 2 materialized views for performance
- 5 stored functions
- 3 stored procedures
- 10+ indexes

## Challenges and Solutions

| Challenge | Solution |
|-----------|----------|
| pgAdmin CSV import failing | Created load_data.sql with multiple import methods |
| Reserved word conflicts | Renamed `count` to `record_count` |
| NULL total_charges | Used COALESCE and NULLIF for safe handling |
| Query performance | Added indexes and rewrote subqueries |

## Lessons Learned

1. **Schema design matters** - Proper constraints prevent bad data
2. **Indexes are not free** - Each adds write overhead
3. **Window functions beat subqueries** - More readable, often faster
4. **Views simplify reporting** - Business users don't need to write complex SQL
5. **Validation is critical** - Always verify data after import

## Future Improvements

1. Add time-series analysis with date dimensions
2. Implement machine learning predictions in SQL
3. Create automated ETL pipeline with dbt
4. Build Power BI dashboard connected to PostgreSQL
5. Add row-level security for multi-tenant access

## Deliverables

- [x] 194 SQL queries and objects
- [x] Production-ready schema with constraints
- [x] Data import scripts (3 methods)
- [x] Data validation suite
- [x] Views for reporting
- [x] Performance optimization
- [x] Documentation
- [x] Portfolio materials
