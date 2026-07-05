-- ============================================================
-- Telecom SQL Analytics Platform
-- Schema: create_tables.sql
-- PostgreSQL 14+ Compatible
-- ============================================================
-- Description: Creates the telecom_churn table with proper
-- constraints, data types, and comments for the IBM Telco
-- Customer Churn dataset.
-- ============================================================

-- Drop existing objects safely
DROP TABLE IF EXISTS telecom_churn CASCADE;

-- ============================================================
-- MAIN TABLE
-- ============================================================

CREATE TABLE telecom_churn (
    -- Primary Key
    customer_id         VARCHAR(50)    NOT NULL,

    -- Metadata (constant in dataset, kept for completeness)
    record_count        SMALLINT       NOT NULL DEFAULT 1,
    country             VARCHAR(100)   NOT NULL DEFAULT 'United States',
    state               VARCHAR(100)   NOT NULL DEFAULT 'California',

    -- Location
    city                VARCHAR(100)   NOT NULL,
    zip_code            VARCHAR(10)    NOT NULL,
    lat_long            VARCHAR(100),
    latitude            DECIMAL(10, 8),
    longitude           DECIMAL(11, 8),

    -- Demographics
    gender              VARCHAR(10)    NOT NULL,
    senior_citizen      VARCHAR(5)     NOT NULL,
    partner             VARCHAR(5)     NOT NULL,
    dependents          VARCHAR(5)     NOT NULL,

    -- Account
    tenure_months       SMALLINT       NOT NULL,
    phone_service       VARCHAR(5)     NOT NULL,
    multiple_lines      VARCHAR(25)    NOT NULL,
    internet_service    VARCHAR(20)    NOT NULL,
    online_security     VARCHAR(25)    NOT NULL,
    online_backup       VARCHAR(25)    NOT NULL,
    device_protection   VARCHAR(25)    NOT NULL,
    tech_support        VARCHAR(25)    NOT NULL,
    streaming_tv        VARCHAR(25)    NOT NULL,
    streaming_movies    VARCHAR(25)    NOT NULL,
    contract            VARCHAR(30)    NOT NULL,
    paperless_billing   VARCHAR(5)     NOT NULL,
    payment_method      VARCHAR(30)    NOT NULL,

    -- Charges
    monthly_charges     DECIMAL(10, 2) NOT NULL,
    total_charges       DECIMAL(10, 2),

    -- Churn Labels
    churn_label         VARCHAR(5)     NOT NULL,
    churn_value         SMALLINT       NOT NULL,
    churn_score         SMALLINT,
    cltv                INTEGER,
    churn_reason        TEXT,

    -- Constraints
    CONSTRAINT pk_telecom_churn PRIMARY KEY (customer_id),
    CONSTRAINT chk_gender CHECK (gender IN ('Male', 'Female')),
    CONSTRAINT chk_senior_citizen CHECK (senior_citizen IN ('Yes', 'No')),
    CONSTRAINT chk_partner CHECK (partner IN ('Yes', 'No')),
    CONSTRAINT chk_dependents CHECK (dependents IN ('Yes', 'No')),
    CONSTRAINT chk_phone_service CHECK (phone_service IN ('Yes', 'No')),
    CONSTRAINT chk_churn_label CHECK (churn_label IN ('Yes', 'No')),
    CONSTRAINT chk_churn_value CHECK (churn_value IN (0, 1)),
    CONSTRAINT chk_tenure_months CHECK (tenure_months >= 0),
    CONSTRAINT chk_monthly_charges CHECK (monthly_charges >= 0),
    CONSTRAINT chk_total_charges CHECK (total_charges >= 0),
    CONSTRAINT chk_paperless_billing CHECK (paperless_billing IN ('Yes', 'No'))
);

-- ============================================================
-- TABLE COMMENT
-- ============================================================

COMMENT ON TABLE telecom_churn IS 'IBM Telco Customer Churn dataset - 7,043 customers with demographics, services, charges, and churn indicators';

-- ============================================================
-- COLUMN COMMENTS
-- ============================================================

COMMENT ON COLUMN telecom_churn.customer_id IS 'Unique customer identifier (Primary Key)';
COMMENT ON COLUMN telecom_churn.record_count IS 'Record count (always 1 in this dataset)';
COMMENT ON COLUMN telecom_churn.country IS 'Country (United States)';
COMMENT ON COLUMN telecom_churn.state IS 'State (California)';
COMMENT ON COLUMN telecom_churn.city IS 'City of residence';
COMMENT ON COLUMN telecom_churn.zip_code IS 'ZIP code';
COMMENT ON COLUMN telecom_churn.lat_long IS 'Combined latitude and longitude string';
COMMENT ON COLUMN telecom_churn.latitude IS 'Geographic latitude';
COMMENT ON COLUMN telecom_churn.longitude IS 'Geographic longitude';
COMMENT ON COLUMN telecom_churn.gender IS 'Customer gender: Male or Female';
COMMENT ON COLUMN telecom_churn.senior_citizen IS 'Senior citizen status: Yes or No';
COMMENT ON COLUMN telecom_churn.partner IS 'Has partner: Yes or No';
COMMENT ON COLUMN telecom_churn.dependents IS 'Has dependents: Yes or No';
COMMENT ON COLUMN telecom_churn.tenure_months IS 'Number of months as customer (0-72)';
COMMENT ON COLUMN telecom_churn.phone_service IS 'Phone service subscribed: Yes or No';
COMMENT ON COLUMN telecom_churn.multiple_lines IS 'Multiple lines: Yes, No, or No phone service';
COMMENT ON COLUMN telecom_churn.internet_service IS 'Internet service: DSL, Fiber optic, or No';
COMMENT ON COLUMN telecom_churn.online_security IS 'Online security: Yes, No, or No internet service';
COMMENT ON COLUMN telecom_churn.online_backup IS 'Online backup: Yes, No, or No internet service';
COMMENT ON COLUMN telecom_churn.device_protection IS 'Device protection: Yes, No, or No internet service';
COMMENT ON COLUMN telecom_churn.tech_support IS 'Tech support: Yes, No, or No internet service';
COMMENT ON COLUMN telecom_churn.streaming_tv IS 'Streaming TV: Yes, No, or No internet service';
COMMENT ON COLUMN telecom_churn.streaming_movies IS 'Streaming movies: Yes, No, or No internet service';
COMMENT ON COLUMN telecom_churn.contract IS 'Contract type: Month-to-month, One year, or Two year';
COMMENT ON COLUMN telecom_churn.paperless_billing IS 'Paperless billing: Yes or No';
COMMENT ON COLUMN telecom_churn.payment_method IS 'Payment method type';
COMMENT ON COLUMN telecom_churn.monthly_charges IS 'Monthly charges in USD';
COMMENT ON COLUMN telecom_churn.total_charges IS 'Total charges in USD (NULL for new customers)';
COMMENT ON COLUMN telecom_churn.churn_label IS 'Churn label: Yes (churned) or No (active)';
COMMENT ON COLUMN telecom_churn.churn_value IS 'Churn value: 1 (churned) or 0 (active)';
COMMENT ON COLUMN telecom_churn.churn_score IS 'Predicted churn probability score (0-100)';
COMMENT ON COLUMN telecom_churn.cltv IS 'Customer Lifetime Value score';
COMMENT ON COLUMN telecom_churn.churn_reason IS 'Stated reason for churn (NULL if active)';

-- ============================================================
-- INDEXES (created after table for clean setup)
-- ============================================================

-- Primary lookup index (implicit from PRIMARY KEY, but explicit for clarity)
-- CREATE INDEX idx_telecom_churn_customer_id ON telecom_churn(customer_id);

-- High-selectivity filter indexes
CREATE INDEX idx_telecom_churn_churn_label ON telecom_churn(churn_label);
CREATE INDEX idx_telecom_churn_contract ON telecom_churn(contract);
CREATE INDEX idx_telecom_churn_internet_service ON telecom_churn(internet_service);

-- Composite indexes for common query patterns
CREATE INDEX idx_telecom_churn_contract_churn ON telecom_churn(contract, churn_label);
CREATE INDEX idx_telecom_churn_contract_charges ON telecom_churn(contract, monthly_charges);
CREATE INDEX idx_telecom_churn_churn_charges ON telecom_churn(churn_label, monthly_charges);

-- Range query indexes
CREATE INDEX idx_telecom_churn_monthly_charges ON telecom_churn(monthly_charges);
CREATE INDEX idx_telecom_churn_total_charges ON telecom_churn(total_charges);
CREATE INDEX idx_telecom_churn_tenure_months ON telecom_churn(tenure_months);

-- Score and value indexes
CREATE INDEX idx_telecom_churn_churn_score ON telecom_churn(churn_score);
CREATE INDEX idx_telecom_churn_cltv ON telecom_churn(cltv);

-- Covering index for most common analytical queries
CREATE INDEX idx_telecom_churn_analytics ON telecom_churn(
    contract, internet_service, churn_label, monthly_charges, tenure_months
);

-- ============================================================
-- TABLE STATISTICS
-- ============================================================

ANALYZE telecom_churn;

-- ============================================================
-- VERIFICATION
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE 'Table telecom_churn created successfully';
    RAISE NOTICE 'Columns: %', (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'telecom_churn');
    RAISE NOTICE 'Indexes: %', (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'telecom_churn');
END $$;
