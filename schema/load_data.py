#!/usr/bin/env python3
"""
Telecom SQL Analytics Platform - Data Loader
Loads telecom_churn_clean.csv into PostgreSQL database.
"""
import psycopg2
import csv
import os
import sys

# Configuration
DB_CONFIG = {
    'dbname': 'telecom_analytics_v2',
    'user': 'postgres',
    'password': 'Suraj@27251',
    'host': 'localhost',
    'port': '5432'
}

# Find the CSV file
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
CSV_FILE = os.path.join(PROJECT_DIR, 'data', 'telecom_churn_clean.csv')

if not os.path.exists(CSV_FILE):
    print(f"ERROR: CSV file not found: {CSV_FILE}")
    print("Please run the data cleaning script first.")
    sys.exit(1)

print(f"Connecting to database: {DB_CONFIG['dbname']}")
print(f"Loading CSV: {CSV_FILE}")

try:
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    # Check current row count
    cur.execute("SELECT COUNT(*) FROM telecom_churn")
    current_count = cur.fetchone()[0]
    if current_count > 0:
        print(f"Table already has {current_count} rows. Truncating...")
        cur.execute("TRUNCATE TABLE telecom_churn")
    
    # Load CSV
    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)  # Skip header
        count = 0
        for row in reader:
            # Handle empty total_charges (convert to None for NULL)
            if len(row) >= 28:
                if row[27].strip() == '':
                    row[27] = None
                if row[32].strip() == '':
                    row[32] = None
            
            cur.execute("""
                INSERT INTO telecom_churn (
                    customer_id, record_count, country, state, city, zip_code,
                    lat_long, latitude, longitude, gender, senior_citizen,
                    partner, dependents, tenure_months, phone_service,
                    multiple_lines, internet_service, online_security,
                    online_backup, device_protection, tech_support,
                    streaming_tv, streaming_movies, contract, paperless_billing,
                    payment_method, monthly_charges, total_charges,
                    churn_label, churn_value, churn_score, cltv, churn_reason
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                          %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                          %s, %s, %s, %s, %s, %s, %s)
            """, row)
            count += 1
    
    conn.commit()
    print(f"Successfully loaded {count} rows")
    
    # Verify
    cur.execute("SELECT COUNT(*) FROM telecom_churn")
    final_count = cur.fetchone()[0]
    print(f"Final row count: {final_count}")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)
