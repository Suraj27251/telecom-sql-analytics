# BUG_REPORT.md

## Telecom SQL Analytics Platform - Bug Report

**Report Date:** 2026-07-05  
**Severity Scale:** CRITICAL | HIGH | MEDIUM | LOW

---

## Bug #1: CSV Import Failure - Empty total_charges

**Severity:** CRITICAL  
**Status:** RESOLVED  
**Files Modified:** data/telecom_churn_clean.csv (new), schema/load_data.sql, schema/load_data.py

### Description
Original `telecom_churn.csv` contains 11 rows where the `total_charges` column has a space character (` `) instead of a numeric value or NULL. This causes PostgreSQL COPY command to fail with:

```
ERROR: invalid input syntax for type numeric: " "
```

### Root Cause
Source data quality issue in IBM Telco Customer Churn dataset. 11 customers with 0 tenure have empty total_charges represented as a space.

### Affected Rows
- Line 2236: 4472-LVYGI
- Line 2440: 3115-CZMZD
- Line 2570: 5709-LVOEQ
- Line 2669: 4367-NUYAO
- Line 2858: 1371-DWPAZ
- Line 4333: 7644-OMVMY
- Line 4689: 3213-VVOLG
- Line 5106: 2520-SGTTA
- Line 5721: 2923-ARZLG
- Line 6774: 4075-WKNIU
- Line 6842: 2775-SEFEE

### Resolution
1. Created `telecom_churn_clean.csv` with spaces replaced by empty values
2. Added `load_data.py` script with proper NULL handling
3. Updated `load_data.sql` with corrected instructions

### Verification
```sql
SELECT COUNT(*) FROM telecom_churn WHERE total_charges IS NULL;
-- Result: 11 (matches expected)
```

---

## Bug #2: Reserved Word Conflict

**Severity:** HIGH  
**Status:** RESOLVED  
**Files Modified:** schema/create_tables.sql

### Description
Original schema used `count` as a column name, which is a PostgreSQL reserved word.

### Root Cause
Direct mapping from CSV column names without checking reserved words.

### Resolution
Renamed column to `record_count` with DEFAULT 1.

### Verification
```sql
SELECT record_count FROM telecom_churn LIMIT 1;
-- Result: 1
```

---

## Bug #3: Missing CHECK Constraints

**Severity:** MEDIUM  
**Status:** RESOLVED  
**Files Modified:** schema/create_tables.sql

### Description
Original schema lacked CHECK constraints for data validation, allowing invalid values.

### Root Cause
Schema designed without business rule enforcement.

### Resolution
Added 11 CHECK constraints:
- chk_gender: gender IN ('Male', 'Female')
- chk_senior_citizen: senior_citizen IN ('Yes', 'No')
- chk_partner: partner IN ('Yes', 'No')
- chk_dependents: dependents IN ('Yes', 'No')
- chk_phone_service: phone_service IN ('Yes', 'No')
- chk_churn_label: churn_label IN ('Yes', 'No')
- chk_churn_value: churn_value IN (0, 1)
- chk_tenure_months: tenure_months >= 0
- chk_monthly_charges: monthly_charges >= 0
- chk_total_charges: total_charges >= 0
- chk_paperless_billing: paperless_billing IN ('Yes', 'No')

### Verification
```sql
SELECT COUNT(*) FROM pg_constraint WHERE conrelid = 'telecom_churn'::regclass AND contype = 'c';
-- Result: 11
```

---

## Bug #4: Broken EXISTS Subquery

**Severity:** MEDIUM  
**Status:** RESOLVED  
**Files Modified:** queries/03_subqueries.sql

### Description
Original Query 10 used a broken EXISTS pattern with `LIMIT 1` subquery.

### Root Cause
Incorrect subquery construction attempting to check for service add-ons.

### Resolution
Replaced with simple OR conditions on the same row.

### Before
```sql
WHERE EXISTS (
    SELECT 1
    FROM (SELECT customer_id FROM telecom_churn LIMIT 1) t2
    WHERE t2.customer_id = t1.customer_id
        AND (t1.online_security = 'Yes' ...)
)
```

### After
```sql
WHERE t1.online_security = 'Yes'
    OR t1.online_backup = 'Yes'
    OR t1.device_protection = 'Yes'
    OR t1.tech_support = 'Yes'
```

---

## Bug #5: Missing NOT NULL Constraints

**Severity:** MEDIUM  
**Status:** RESOLVED  
**Files Modified:** schema/create_tables.sql

### Description
Original schema allowed NULLs in columns that should never be NULL.

### Root Cause
Permissive schema design.

### Resolution
Added NOT NULL to 26 columns (all except lat_long, latitude, longitude, total_charges, churn_score, cltv, churn_reason).

---

## Bug #6: Missing Column Comments

**Severity:** LOW  
**Status:** RESOLVED  
**Files Modified:** schema/create_tables.sql

### Description
Original schema lacked column comments for documentation.

### Resolution
Added COMMENT ON COLUMN for all 33 columns.

### Verification
```sql
SELECT COUNT(*) FROM pg_description 
WHERE objoid = 'telecom_churn'::regclass 
AND objsubid > 0;
-- Result: 33
```

---

## Bug #7: Duplicate Query in Window Functions

**Severity:** LOW  
**Status:** RESOLVED  
**Files Modified:** queries/02_window_functions.sql

### Description
Query 6 and Query 12 both attempted to filter for customers with COUNT(*) > 1, which is impossible in a table with unique customer_id.

### Root Cause
Copy-paste error from template.

### Resolution
Rewrote queries to use different window function patterns.

---

## Bug #8: setup.md Missing CSV Cleaning Step

**Severity:** HIGH  
**Status:** RESOLVED  
**Files Modified:** setup.md

### Description
Original setup instructions didn't mention the CSV cleaning step required for successful import.

### Resolution
Updated setup.md to:
1. Reference `telecom_churn_clean.csv`
2. Include Python cleaning script
3. Provide multiple import methods

---

## Bug #9: Missing LOAD_DATA.py Script

**Severity:** MEDIUM  
**Status:** RESOLVED  
**Files Modified:** schema/load_data.py (new)

### Description
No programmatic import method was available.

### Resolution
Created `load_data.py` with:
- psycopg2 connection
- CSV parsing
- NULL handling
- Progress reporting
- Error handling

---

## Bug #10: Redundant Indexes

**Severity:** LOW  
**Status:** RESOLVED  
**Files Modified:** queries/07_indexes_optimization.sql

### Description
Some indexes in 07_indexes_optimization.sql overlapped with indexes in create_tables.sql.

### Resolution
- Removed duplicate index creation attempts
- Added `IF NOT EXISTS` where appropriate
- Documented index purposes

---

## Summary

| Severity | Count | Resolved |
|----------|-------|----------|
| CRITICAL | 1 | 1 |
| HIGH | 2 | 2 |
| MEDIUM | 4 | 4 |
| LOW | 3 | 3 |
| **TOTAL** | **10** | **10** |

**All bugs resolved. No outstanding issues.**
