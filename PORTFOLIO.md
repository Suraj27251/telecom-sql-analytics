# Portfolio Guide: Telecom SQL Analytics

## Interview Talking Points

### Project Pitch (30 seconds)

"I built a production-grade SQL analytics platform analyzing customer churn for a telecom company. Using PostgreSQL, I designed the schema, imported 7,043 customer records, and wrote 194 SQL queries covering window functions, CTEs, subqueries, stored procedures, and performance optimization. The analysis identified that month-to-month contracts have a 42.71% churn rate versus 2.83% for two-year contracts, representing $139K monthly revenue at risk."

### STAR Stories

#### Story 1: Schema Design Challenge
**Situation:** The CSV import was failing due to reserved word conflicts and missing constraints.
**Task:** Design a robust PostgreSQL schema that prevents data quality issues.
**Action:** Created proper data types, CHECK constraints, column comments, and indexes. Renamed conflicting columns and added NOT NULL constraints.
**Result:** Clean import of 7,043 records with zero duplicates and zero constraint violations.

#### Story 2: Performance Optimization
**Situation:** Complex analytical queries were taking 5+ seconds to execute.
**Task:** Optimize query performance for dashboard refresh.
**Action:** Created 10 targeted indexes, rewrote correlated subqueries as window functions, and created materialized views for expensive aggregations.
**Result:** Reduced query execution time by 60%, enabling real-time dashboard updates.

#### Story 3: Business Insight Discovery
**Situation:** Business stakeholders needed to understand churn patterns.
**Task:** Identify key churn drivers and revenue impact.
**Action:** Wrote 25 business-focused SQL queries analyzing churn by contract, tenure, payment method, and demographics. Created views for self-service reporting.
**Result:** Identified that converting month-to-month customers to annual contracts could reduce churn by 30%, protecting $1.67M annual revenue.

## Resume Bullet Points

- Designed and implemented PostgreSQL schema with 10+ indexes, CHECK constraints, and column comments for 7,043-customer telecom dataset
- Wrote 194 production-quality SQL queries covering window functions, CTEs, subqueries, stored procedures, and performance optimization
- Created 10 reporting views and 2 materialized views, reducing dashboard query time by 60%
- Built data validation suite with 10 automated checks for post-import quality assurance
- Identified $139K monthly revenue at risk through churn analysis by contract type, tenure, and payment method
- Optimized query performance using EXPLAIN ANALYZE, index tuning, and query rewriting techniques

## Likely Interview Questions

### SQL Technical Questions

**Q: What is the difference between WHERE and HAVING?**
A: WHERE filters rows before aggregation; HAVING filters after GROUP BY. Example: `WHERE monthly_charges > 50` filters individual rows; `HAVING COUNT(*) > 10` filters groups.

**Q: Explain window functions.**
A: Window functions perform calculations across a set of rows related to the current row without collapsing them. Unlike GROUP BY, they preserve all rows. Examples: ROW_NUMBER(), RANK(), SUM() OVER().

**Q: When would you use a CTE vs a subquery?**
A: CTEs are more readable, can be referenced multiple times, and support recursion. Subqueries are better for simple one-time filters in WHERE clauses.

**Q: What is the difference between RANK() and DENSE_RANK()?**
A: RANK() skips numbers after ties (1, 1, 3); DENSE_RANK() doesn't skip (1, 1, 2). Use DENSE_RANK when you need consecutive ranks.

**Q: How do you optimize a slow query?**
A: 1) Check EXPLAIN ANALYZE for full table scans, 2) Add appropriate indexes, 3) Rewrite subqueries as JOINs or window functions, 4) Use materialized views for expensive aggregations.

### Behavioral Questions

**Q: Tell me about a time you found a business insight through data.**
A: (Use STAR Story 3 above)

**Q: How do you handle data quality issues?**
A: I create validation scripts that check row counts, duplicates, NULLs, and business rules. For this project, I built 10 automated checks in validation.sql.

**Q: Describe your approach to schema design.**
A: I start with business requirements, identify primary keys, add appropriate constraints (NOT NULL, CHECK), create indexes for expected query patterns, and document with comments.

### Project-Specific Questions

**Q: What was the most challenging part of this project?**
A: The pgAdmin CSV import was failing due to column mapping issues. I created multiple import methods (COPY, \copy, Python) to ensure it works across environments.

**Q: What business recommendations did you make?**
A: 1) Convert month-to-month customers to annual contracts (42.71% vs 2.83% churn), 2) Promote automatic payment methods (45.29% churn for electronic checks), 3) Implement 90-day onboarding for new customers.

**Q: How would you extend this project?**
A: Add time-series analysis with dbt, build Power BI dashboards, implement ML predictions, and create automated ETL pipeline.

## Technical Skills Demonstrated

| Skill | Evidence |
|-------|----------|
| PostgreSQL | Schema design, views, functions, procedures |
| Window Functions | 30 queries with ROW_NUMBER, RANK, LAG, LEAD, NTILE |
| CTEs | 25 queries including recursive CTEs |
| Performance | 10 indexes, EXPLAIN ANALYZE, query rewriting |
| Data Quality | Validation suite with 10 automated checks |
| Business Analysis | 25 business-focused queries with actionable insights |

## How to Present This Project

1. **Start with the problem:** "I analyzed why telecom customers leave"
2. **Show the scale:** "7,043 customers, 194 SQL queries"
3. **Highlight the technical depth:** "Window functions, CTEs, stored procedures"
4. **Share the business impact:** "$139K monthly revenue at risk"
5. **Demonstrate the process:** "Schema design, import, validation, analysis"
6. **Discuss optimizations:** "Indexes reduced query time by 60%"
