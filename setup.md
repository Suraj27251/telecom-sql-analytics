# Setup Guide: Telecom SQL Analytics Platform

> Follow these steps to get the project running in under 10 minutes.

## Prerequisites

- PostgreSQL 14+ installed (tested on PostgreSQL 18.4)
- pgAdmin 4 or DBeaver (or psql command line)
- Python 3.6+ (optional, for Python import method)

## Step 1: Clone or Download

```bash
git clone https://github.com/yourusername/telecom-sql-analytics.git
cd telecom-sql-analytics
```

Or download the ZIP file and extract it.

## Step 2: Create Database

### Using psql:
```bash
psql -U postgres -c "CREATE DATABASE telecom_analytics;"
```

### Using pgAdmin:
1. Open pgAdmin
2. Right-click on "Databases"
3. Click "Create" > "Database"
4. Name it: `telecom_analytics`
5. Click "Save"

## Step 3: Create Schema

```bash
psql -U postgres -d telecom_analytics -f schema/create_tables.sql
```

Expected output:
```
NOTICE:  Table telecom_churn created successfully
NOTICE:  Columns: 33
NOTICE:  Indexes: 13
```

## Step 4: Import Data

### Method A: Command Line (Recommended)

```bash
psql -U postgres -d telecom_analytics -c "\copy telecom_churn FROM 'C:/path/to/telecom-sql-analytics/data/telecom_churn_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')"
```

### Method B: Python Script (Most Reliable)

1. Install psycopg2:
```bash
pip install psycopg2-binary
```

2. Edit `schema/load_data.py` and update the password

3. Run:
```bash
python schema/load_data.py
```

Expected output:
```
Successfully loaded 7043 rows
Final row count: 7043
```

### Method C: pgAdmin Query Tool

Open pgAdmin -> Query Tool and run:

```sql
COPY telecom_churn FROM 'C:/Users/suraj/OneDrive/Desktop/telecom-sql-analytics/data/telecom_churn_clean.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

**IMPORTANT:** Use `telecom_churn_clean.csv`, NOT `telecom_churn.csv`. The original CSV has 11 rows with empty total_charges that will cause import errors.

## Step 5: Validate Import

```bash
psql -U postgres -d telecom_analytics -f schema/validation.sql
```

Expected output:
```
NOTICE:  ALL CHECKS PASSED
```

## Step 6: Run All Queries

```bash
psql -U postgres -d telecom_analytics -f queries/01_basic.sql
psql -U postgres -d telecom_analytics -f queries/02_window_functions.sql
psql -U postgres -d telecom_analytics -f queries/03_subqueries.sql
psql -U postgres -d telecom_analytics -f queries/04_cte.sql
psql -U postgres -d telecom_analytics -f queries/05_business_questions.sql
psql -U postgres -d telecom_analytics -f queries/06_views.sql
psql -U postgres -d telecom_analytics -f queries/07_indexes_optimization.sql
psql -U postgres -d telecom_analytics -f queries/08_stored_procedures_functions.sql
psql -U postgres -d telecom_analytics -f queries/09_advanced_analytics.sql
```

## Step 7: Verify Views

```sql
SELECT * FROM vw_customer_summary LIMIT 5;
SELECT * FROM vw_executive_dashboard;
SELECT * FROM vw_contract_performance;
```

## Quick Test Queries

```sql
-- Verify row count (should be 7043)
SELECT COUNT(*) FROM telecom_churn;

-- Show sample data
SELECT customer_id, contract, monthly_charges, churn_label 
FROM telecom_churn LIMIT 5;

-- Show churn rate
SELECT 
    ROUND(SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM telecom_churn;
```

## Troubleshooting

### Error: "relation telecom_churn does not exist"
**Solution:** Run `schema/create_tables.sql` first.

### Error: "invalid input syntax for type numeric"
**Solution:** You're using the original CSV. Use `telecom_churn_clean.csv` instead.

### Error: "could not open file"
**Solution:** The file path is wrong. Use forward slashes `/` instead of backslashes `\`.

### Error: "permission denied"
**Solution:** Make sure PostgreSQL has read access to the CSV file location.

### Error: "duplicate key value violates unique constraint"
**Solution:** The data was already imported. Drop and recreate:
```sql
DROP TABLE telecom_churn CASCADE;
-- Then run create_tables.sql again
```

## Database Objects Created

After running all scripts, you should have:

| Object Type | Count |
|-------------|-------|
| Tables | 2 (telecom_churn, audit_log) |
| Views | 10 |
| Materialized Views | 2 |
| Indexes | 24 |
| Functions | 6 |
| Procedures | 3 |
| Total | 47 |

## Next Steps

1. Run through all query files in order
2. Review the views in `06_views.sql`
3. Check performance optimization in `07_indexes_optimization.sql`
4. Read the business analysis in `05_business_questions.sql`
5. Check `PORTFOLIO.md` for interview preparation
6. Review `FINAL_AUDIT.md` for complete verification results
