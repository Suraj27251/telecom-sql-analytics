# Telecom Customer Churn Analytics Platform

> End-to-end analytics platform analyzing customer churn for a telecom company using PostgreSQL, Azure Functions REST API, React dashboard, and advanced SQL.

## Overview

This project analyzes customer churn in a telecom company using PostgreSQL and an interactive React dashboard. The objective is to identify customer behaviors associated with churn and build interactive dashboards for business decision-making.

The platform covers the full data analytics pipeline — from schema design and advanced SQL analytics to a production REST API and a modern BI-style React dashboard.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Database | PostgreSQL 18.4 |
| Language | SQL (PostgreSQL dialect), Python, JavaScript |
| API | Azure Functions, psycopg3 |
| Frontend | React 19, Vite, Material UI, Recharts |
| Transformation | dbt |
| Data Format | CSV, XLSX |

## Dataset

| Property | Value |
|----------|-------|
| Source | IBM Telco Customer Churn |
| Records | 7,043 customer records |
| Columns | 33 customer attributes |
| Database | `telecom_analytics_v2` |

**Attributes include:**
- Customer demographics (gender, senior citizen, partner, dependents)
- Services (phone, internet, streaming, security)
- Contract & payment information
- Monthly & total charges
- Customer lifetime value (CLTV)
- Churn status & reasons

## Architecture

```
                React Dashboard (Vite + MUI + Recharts)
                              │
                              ▼
                Azure Functions REST API (Python)
                              │
                              ▼
                   PostgreSQL Database
                   (telecom_analytics_v2)
                              │
                              ▼
              Advanced SQL Analytics Layer
              (194 queries, views, procedures)
```

## Project Structure

```
telecom-sql-analytics/
├── api/                                # Azure Functions REST API
│   ├── function_app.py                 # 10 HTTP endpoints
│   ├── db.py                           # PostgreSQL connection management
│   ├── queries.py                      # Parameterized SQL queries
│   └── API_DOCUMENTATION.md            # Endpoint documentation
│
├── dashboard/                          # React Analytics Dashboard
│   └── src/
│       ├── api/index.js                # API service layer
│       ├── components/                 # Layout, KPI cards, filters, skeletons
│       ├── pages/                      # 6 pages: Dashboard, Customers, Churn, Revenue, SQL Explorer, About
│       └── theme.js                    # MUI theme with consistent color palette
│
├── schema/                             # Database schema
│   ├── create_tables.sql               # DDL with constraints, indexes, comments
│   ├── load_data.sql                   # CSV import methods
│   ├── load_data.py                    # Python import script
│   └── validation.sql                  # Post-import data quality checks
│
├── queries/                            # SQL analytics (194 objects)
│   ├── 01_basic.sql                    # 30 queries: Aggregations, GROUP BY, CASE
│   ├── 02_window_functions.sql         # 30 queries: ROW_NUMBER, RANK, LAG, LEAD, NTILE
│   ├── 03_subqueries.sql              # 25 queries: Correlated, EXISTS, IN
│   ├── 04_cte.sql                      # 25 queries: CTEs, Recursive CTEs
│   ├── 05_business_questions.sql       # 25 queries: KPIs, Revenue, Segmentation
│   ├── 06_views.sql                    # 10 views + 2 materialized views
│   ├── 07_indexes_optimization.sql     # 10 indexes + EXPLAIN ANALYZE tests
│   ├── 08_stored_procedures_functions.sql  # 5 functions, 3 procedures, triggers
│   └── 09_advanced_analytics.sql       # 20 queries: Pivoting, String/Date, Complex
│
├── data/
│   ├── Telco_customer_churn.xlsx       # Source data
│   ├── telecom_churn.csv               # CSV export (7,043 rows)
│   └── telecom_churn_clean.csv         # Cleaned CSV (fixed 11 blank total_charges)
│
├── telecom_dbt/                        # dbt transformation layer
│   ├── models/
│   ├── macros/
│   ├── seeds/
│   └── tests/
│
├── screenshots/                        # Dashboard screenshots
│
├── README.md
├── report.md
├── PORTFOLIO.md
└── setup.md
```

## REST API

10 endpoints powering the dashboard:

| Endpoint | Description |
|----------|-------------|
| `GET /api/dashboard` | Executive KPIs (total customers, revenue, churn rate, avg charges) |
| `GET /api/customers` | Paginated customer list with search |
| `GET /api/customer?id=XX` | Full customer detail by ID |
| `GET /api/churn` | Churn distribution by label |
| `GET /api/contracts` | Contract type distribution |
| `GET /api/topcities` | Top 10 cities by customer count |
| `GET /api/revenue` | Top 10 cities by revenue |
| `GET /api/monthlycharges` | Monthly charges statistics (avg, min, max, median) |
| `GET /api/internet` | Internet service breakdown |
| `GET /api/churnreasons` | Top 15 churn reasons |

**Running the API:**
```bash
cd api
pip install -r requirements.txt
func start
# API available at http://localhost:7071/api/
```

## Dashboard

6-page React analytics dashboard:

### Executive Dashboard
- **KPI Cards:** Total Customers, Total Revenue, Churn Rate, Avg Monthly Charges
- **Charts:** Revenue by City (bar), Churn Breakdown (pie), Contract Distribution (donut), Internet Service (bar), Monthly Charges Distribution
- **Drill-down:** Click any city bar to see detailed city analytics

### Customers
- Search by Customer ID or City
- Sortable columns: Customer ID, City, State, Monthly Charges, Status
- Pagination (10, 20, 50 per page)
- Click row for full customer detail drawer

### Churn Analysis
- Top 15 churn reasons (horizontal bar)
- Churn by label (pie)
- Churn by contract type (bar)
- Churn by internet service (bar)

### Revenue Analysis
- Revenue by city (bar chart)
- Revenue leaderboard with rankings
- Monthly charges KPIs (average, median, max)

### SQL Explorer
- View all 10 SQL queries powering the API
- Syntax-highlighted code blocks
- Endpoint reference for each query
- Database schema information

### About Project
- Architecture diagram
- Tech stack overview
- Dataset information
- Key features checklist

**Running the Dashboard:**
```bash
cd dashboard
npm install
npm run dev
# Dashboard available at http://localhost:3000
```

## SQL Techniques Demonstrated

| Category | Techniques | Queries |
|----------|-----------|---------|
| **Aggregations** | COUNT, SUM, AVG, GROUP BY, HAVING | 30 |
| **Window Functions** | ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE, PERCENT_RANK | 30 |
| **Subqueries** | Correlated, Scalar, EXISTS, NOT EXISTS, IN | 25 |
| **CTEs** | Basic, Multi-level, Recursive | 25 |
| **Business Analytics** | KPIs, Revenue Analysis, Segmentation | 25 |
| **Views** | Standard Views, Materialized Views | 12 |
| **Optimization** | Indexes, EXPLAIN ANALYZE, Query Rewriting | 15 |
| **Procedures** | Functions, Stored Procedures, Triggers | 12 |
| **Advanced** | Pivoting, String Functions, CASE, COALESCE | 20 |

**Total: 194 SQL queries and objects**

## Business Questions Answered

1. What is the overall churn rate and revenue impact?
2. Which contract types have the highest churn?
3. How does internet service affect retention?
4. What are the top reasons customers leave?
5. Which payment methods correlate with churn?
6. How does tenure affect churn probability?
7. What is the revenue at risk from churn?
8. Which customer segments are most valuable?
9. How do senior citizens differ in behavior?
10. Where are the highest-risk geographic areas?

## Key Findings

| Metric | Value |
|--------|-------|
| Total Customers | 7,043 |
| Churn Rate | 26.54% |
| Total Revenue | $16.1M |
| Avg Monthly Charge | $64.76 |
| Median Monthly Charge | $70.35 |
| Avg Tenure | 32.37 months |

### Business Insights

- **Month-to-month contracts** experience the highest churn — customers on annual plans are more retained.
- **Fiber optic customers** churn more frequently than DSL users, suggesting pricing or service quality issues.
- **Shorter tenure** correlates with higher churn probability — early engagement is critical.
- **Higher monthly charges** correlate with increased churn — price sensitivity is a key factor.
- **Electronic check** is the most common payment method among churned customers.

## Quick Start

```bash
# 1. Clone repository
git clone https://github.com/yourusername/telecom-sql-analytics.git
cd telecom-sql-analytics

# 2. Create database
psql -U postgres -c "CREATE DATABASE telecom_analytics_v2;"

# 3. Run schema
psql -U postgres -d telecom_analytics_v2 -f schema/create_tables.sql

# 4. Import data
psql -U postgres -d telecom_analytics_v2 -c "\copy telecom_churn FROM 'data/telecom_churn_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')"

# 5. Validate
psql -U postgres -d telecom_analytics_v2 -f schema/validation.sql

# 6. Start API
cd api
pip install -r requirements.txt
func start

# 7. Start Dashboard (new terminal)
cd dashboard
npm install
npm run dev
```

## STAR Stories

### STAR Story 1 — End-to-End Analytics Platform

**Situation:** A telecom dataset contained over 7,000 customer records requiring analysis to understand churn patterns and revenue impact.

**Task:** Build an end-to-end analytics solution from database design to interactive dashboards.

**Action:** Designed PostgreSQL schema with constraints and indexes, wrote 194 SQL queries covering aggregations, window functions, CTEs, and subqueries. Built a REST API with Azure Functions and Python, then created a React dashboard with Material UI and Recharts.

**Result:** Produced a full-stack analytics platform with executive dashboards highlighting churn by contract, tenure, payment method, and internet service, enabling actionable business insights.

### STAR Story 2 — Data Quality Resolution

**Situation:** The PostgreSQL import failed because 11 rows contained blank `total_charges` values, causing type conversion errors during CSV loading.

**Task:** Identify and resolve the import issue to load all customer records.

**Action:** Located the problematic rows using SQL analysis, cleaned the dataset by replacing blank values with calculated charges (tenure × monthly_charges), and created a validated clean CSV file.

**Result:** Successfully loaded all 7,043 customer records into PostgreSQL with zero data quality issues, enabling downstream analytics and API development.

### STAR Story 3 — Interactive Dashboard Delivery

**Situation:** Business users required a single dashboard to monitor customer churn trends, revenue distribution, and customer segments.

**Task:** Create an interactive dashboard providing real-time visibility into churn analytics.

**Action:** Developed a React dashboard with 6 pages, 10 API endpoints, loading skeletons, city drill-down modals, and SQL Explorer. Integrated filter bar for state, contract, internet service, churn status, and gender.

**Result:** Delivered a production-ready dashboard providing instant visibility into churn trends, customer behavior, and revenue impact across all business dimensions.

## Dashboard Screenshots

> Add screenshots to the `screenshots/` folder and reference them here:

```markdown
### Executive Dashboard
![Executive Dashboard](screenshots/executive_dashboard.png)

### Customer Insights
![Customer Insights](screenshots/customer_insights.png)
```

## Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file — project overview and documentation |
| [report.md](report.md) | Executive summary and findings |
| [PORTFOLIO.md](PORTFOLIO.md) | Interview talking points |
| [setup.md](setup.md) | Step-by-step setup guide |
| [API_DOCUMENTATION.md](api/API_DOCUMENTATION.md) | REST API endpoint reference |

## GitHub Topics

```
postgresql powerbi sql dax business-intelligence data-analysis
customer-churn telecom analytics dashboard dbt azure-functions
react material-ui recharts python rest-api
```

## Repository Description

> End-to-end Telecom Customer Churn Analytics project using PostgreSQL, SQL, dbt, Azure Functions, React, and Material UI with interactive business dashboards.

## License

This project is for educational purposes and portfolio development.
#   t e l e c o m - s q l - a n a l y t i c s  
 