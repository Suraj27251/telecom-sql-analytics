# Architecture Documentation

## System Overview

The Telecom Customer Churn Analytics Platform is a full-stack data analytics solution built on a modern cloud-native architecture. It processes 7,043 customer records through multiple layers to deliver interactive business intelligence dashboards.

## High-Level Architecture

```mermaid
flowchart TD
    subgraph DATA["📁 Data Layer"]
        A1[("CSV/XLSX Source<br/>7,043 rows")] --> A2[("PostgreSQL 18.4<br/>telecom_analytics_v2")]
    end

    subgraph SQL["🔍 SQL Analytics Layer"]
        B1[194 SQL Queries] --> B2[Views & Materialized Views]
        B2 --> B3[Stored Procedures & Functions]
        B3 --> B4[Indexes & Optimizations]
    end

    subgraph DBT["🔄 Transformation Layer"]
        C1[Staging Models] --> C2[Intermediate Models]
        C2 --> C3[Mart Models]
        C3 --> C4[Data Quality Tests]
    end

    subgraph API["⚡ API Layer"]
        D1[Azure Functions] --> D2[Python + psycopg3]
        D2 --> D3[Parameterized Queries]
        D3 --> D4[10 REST Endpoints]
    end

    subgraph UI["🖥️ Presentation Layer"]
        E1[React 19 + Vite] --> E2[Material UI]
        E2 --> E3[Recharts]
        E3 --> E4[React Router]
    end

    A2 --> SQL
    A2 --> DBT
    SQL --> API
    DBT --> API
    API --> UI

    style DATA fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    style SQL fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    style DBT fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style API fill:#fce4ec,stroke:#c62828,stroke-width:2px
    style UI fill:#e0f7fa,stroke:#00838f,stroke-width:2px
```

## Layer Details

### 1. Data Layer

**PostgreSQL 18.4 Database** (`telecom_analytics_v2`)

| Property | Value |
|----------|-------|
| Engine | PostgreSQL 18.4 |
| Database | `telecom_analytics_v2` |
| Table | `telecom_churn` |
| Rows | 7,043 |
| Columns | 33 |
| Indexes | 13+ |
| Views | 10+ |

**Schema Design:**
- CHECK constraints on categorical columns (gender, churn_label, contract, etc.)
- Proper data types (NUMERIC for charges, INTEGER for counts)
- Composite and single-column indexes for query optimization
- Comments on all tables and columns

### 2. SQL Analytics Layer

194 SQL objects organized by complexity:

| Category | Count | Techniques |
|----------|-------|------------|
| Basic Aggregations | 30 | COUNT, SUM, AVG, GROUP BY, HAVING |
| Window Functions | 30 | ROW_NUMBER, RANK, LAG, LEAD, NTILE |
| Subqueries | 25 | Correlated, EXISTS, IN |
| CTEs | 25 | Basic, Recursive, Multi-level |
| Business Analytics | 25 | KPIs, Revenue, Segmentation |
| Views | 12 | Standard, Materialized |
| Optimization | 15 | Indexes, EXPLAIN ANALYZE |
| Procedures | 12 | Functions, Triggers |
| Advanced | 20 | Pivoting, String/Date |

### 3. Transformation Layer (dbt)

```mermaid
flowchart LR
    RAW["Raw CSV/XLSX"] --> STG["Staging<br/>(clean, rename, type cast)"]
    STG --> INT["Intermediate<br/>(joins, business logic)"]
    INT --> MART["Mart<br/>(aggregated KPIs)"]
    MART --> TEST["Data Quality Tests"]

    style RAW fill:#e3f2fd,stroke:#1565c0
    style STG fill:#fff3e0,stroke:#ef6c00
    style INT fill:#f3e5f5,stroke:#7b1fa2
    style MART fill:#e8f5e9,stroke:#2e7d32
    style TEST fill:#fce4ec,stroke:#c62828
```

**dbt Project Structure:**
```
telecom_dbt/
├── models/
│   ├── staging/          # Raw data cleaning
│   ├── intermediate/     # Business logic
│   └── marts/            # Aggregated KPIs
├── macros/               # Reusable SQL
├── seeds/                # Static data
├── tests/                # Data quality
└── dbt_project.yml       # Configuration
```

### 4. API Layer

**Azure Functions REST API** (Python)

| Component | Technology |
|-----------|------------|
| Runtime | Azure Functions |
| Language | Python 3.x |
| Driver | psycopg3 |
| Architecture | Clean (routes, SQL, DB separated) |

**Endpoint Architecture:**
```
function_app.py (Routes)  →  queries.py (SQL)  →  db.py (Connection)
        │                          │                      │
        ▼                          ▼                      ▼
   HTTP Request            Parameterized SQL        Connection Pool
        │                          │                      │
        ▼                          ▼                      ▼
   JSON Response            Query Results          PostgreSQL DB
```

**10 REST Endpoints:**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/dashboard` | GET | Executive KPIs |
| `/api/customers` | GET | Paginated customer list |
| `/api/customer` | GET | Single customer detail |
| `/api/churn` | GET | Churn distribution |
| `/api/contracts` | GET | Contract breakdown |
| `/api/topcities` | GET | Top cities by count |
| `/api/revenue` | GET | Top cities by revenue |
| `/api/monthlycharges` | GET | Charge statistics |
| `/api/internet` | GET | Internet service breakdown |
| `/api/churnreasons` | GET | Top churn reasons |

### 5. Presentation Layer

**React Dashboard** (Vite + MUI + Recharts)

| Component | Technology |
|-----------|------------|
| Framework | React 19 |
| Bundler | Vite |
| UI Library | Material UI |
| Charts | Recharts |
| HTTP Client | Axios |
| Routing | React Router |

**6 Dashboard Pages:**
1. **Executive Dashboard** — KPIs + 5 charts + city drill-down
2. **Customers** — Search, sort, paginate, detail drawer
3. **Churn Analysis** — Reasons, contract, internet breakdown
4. **Revenue Analysis** — City revenue, leaderboard, stats
5. **SQL Explorer** — Query viewer with syntax highlighting
6. **About Project** — Architecture, tech stack, features

## Data Flow

```mermaid
sequenceDiagram
    participant U as User
    participant D as React Dashboard
    participant A as Azure Functions API
    participant P as PostgreSQL
    participant S as SQL Analytics

    U->>D: Opens dashboard
    D->>A: GET /api/dashboard
    A->>P: Execute SQL query
    P->>S: Use indexes/views
    S->>P: Return results
    P->>A: Query results
    A->>D: JSON response
    D->>U: Render charts/KPIs

    U->>D: Clicks city bar
    D->>A: GET /api/revenue
    A->>P: SELECT city, revenue
    P->>A: Return data
    A->>D: JSON response
    D->>U: Open drill-down modal
```

## Security

| Measure | Implementation |
|---------|---------------|
| SQL Injection Prevention | Parameterized queries (`%s` placeholders) |
| Connection Security | Environment-based credentials |
| API Authentication | Azure Functions auth levels |
| Input Validation | Query parameter parsing |
| Error Handling | JSON error responses, logging |

## Performance

| Optimization | Details |
|-------------|---------|
| Database Indexes | 13+ indexes on frequently queried columns |
| Connection Management | Context managers with automatic cleanup |
| Query Optimization | EXPLAIN ANALYZE validated |
| Pagination | LIMIT/OFFSET for large datasets |
| Loading States | Skeleton components for perceived performance |

## Deployment

```
┌─────────────────────────────────────────────────────┐
│                   Production                        │
├─────────────────────────────────────────────────────┤
│  React Dashboard  →  Azure Static Web Apps         │
│  Azure Functions  →  Azure Functions App            │
│  PostgreSQL       →  Azure Database for PostgreSQL  │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                   Development                       │
├─────────────────────────────────────────────────────┤
│  React Dashboard  →  localhost:3000 (Vite)          │
│  Azure Functions  →  localhost:7071 (func start)    │
│  PostgreSQL       →  localhost:5432 (local install) │
└─────────────────────────────────────────────────────┘
```

## Technology Decisions

| Choice | Rationale |
|--------|-----------|
| PostgreSQL over MySQL | Advanced window functions, CTEs, PERCENTILE_CONT |
| Azure Functions over Flask | Serverless, auto-scaling, built-in monitoring |
| React over Angular | Larger ecosystem, faster development |
| Material UI over Bootstrap | Pre-built data components, theming |
| Recharts over D3 | Declarative API, React integration |
| psycopg3 over psycopg2 | Modern async support, better type handling |
| dbt for transformations | Version control, testing, documentation |
