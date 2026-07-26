<div align="center">

# 🛒 Walmart Analytics Lakehouse

### End-to-End Retail Data Engineering Platform

**PostgreSQL → CDC → Databricks → Delta Lake → dbt → Apache Airflow**

[![Databricks](https://img.shields.io/badge/Databricks-Lakehouse-FF3621?logo=databricks&logoColor=white)](https://www.databricks.com/)
[![Apache Spark](https://img.shields.io/badge/Apache%20Spark-Distributed%20Processing-E25A1C?logo=apachespark&logoColor=white)](https://spark.apache.org/)
[![Delta Lake](https://img.shields.io/badge/Delta%20Lake-ACID%20Storage-00ADD8)](https://delta.io/)
[![dbt](https://img.shields.io/badge/dbt-Transformation-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-Orchestration-017CEE?logo=apacheairflow&logoColor=white)](https://airflow.apache.org/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-OLTP-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Unity Catalog](https://img.shields.io/badge/Unity%20Catalog-Governance-1F70C1)](https://www.databricks.com/product/unity-catalog)

*A production-inspired data platform that transforms operational retail data into governed and analytics-ready data products.*

[Architecture](#️-end-to-end-architecture) · [Star Schema](#-gold-star-schema) · [Workflow](#️-airflow-orchestration) · [Quality](#️-data-quality--governance) · [Setup](#-getting-started)

</div>

---

## ✨ Project Overview

**Walmart Analytics Lakehouse** is an end-to-end retail data engineering project. Operational data is collected from PostgreSQL, loaded incrementally into Databricks, refined through a Medallion architecture, modeled with dbt, tested automatically, and orchestrated with Apache Airflow.

### 🎯 What this project achieves

- Centralizes **sales, products, stores, and customers** in one governed platform
- Processes source changes incrementally through **CDC**
- Preserves raw data for traceability and recovery
- Produces clean and historical business entities
- Builds a Gold **Star Schema** optimized for analytics
- Automates transformations and tests with **dbt**
- Executes and monitors the full workflow with **Apache Airflow**
- Protects secrets through environment variables instead of hard-coded credentials

---

## 🖼️ End-to-End Architecture

<div align="center">
  <a href="walmart-lakehouse-architecture.png">
    <img src="walmart-lakehouse-architecture.png" alt="Walmart end-to-end analytics lakehouse architecture" width="100%">
  </a>
  <br>
  <sub><b>Figure 1.</b> Complete platform architecture from operational sources to business consumption. Click the image to open it at full size.</sub>
</div>

### 🔎 Architecture in simple terms

| Step | Component | What was implemented |
|---:|---|---|
| 1 | **PostgreSQL OLTP** | Stores operational sales, product, store, and customer records |
| 2 | **Ghost MCP** | Enables controlled natural-language interaction with PostgreSQL through VS Code |
| 3 | **CDC ingestion** | Transfers new and changed records without reloading the entire source |
| 4 | **Bronze** | Preserves raw Delta records with audit and lineage metadata |
| 5 | **Silver** | Cleans, validates, deduplicates, and historizes business entities |
| 6 | **Gold** | Publishes dimensions, facts, and certified retail metrics |
| 7 | **dbt** | Organizes transformations, tests, snapshots, documentation, and lineage |
| 8 | **Airflow** | Runs tasks in the correct order and monitors remote Databricks jobs |
| 9 | **Analytics** | Exposes trusted data for dashboards, reports, and analytical use cases |

---

## 🧭 Conceptual Platform View

<div align="center">
  <a href="data-platform-overview.png">
    <img src="data-platform-overview.png" alt="Conceptual data platform overview" width="100%">
  </a>
  <br>
  <sub><b>Figure 2.</b> Simplified conceptual view of agentic access, incremental loading, quality controls, dbt, and Airflow.</sub>
</div>

> **Scope note:** the AWS S3 block in this conceptual illustration represents an optional file-ingestion path. The implemented core pipeline uses PostgreSQL as its operational source and Delta Lake on Databricks as its analytical storage layer.

---

## 🥉🥈🥇 Medallion Architecture

The Lakehouse is divided into three layers. Each layer has a precise responsibility, making the pipeline easier to understand, test, and recover.

### 🥉 Bronze: Raw & Traceable

Bronze stores source-aligned data before business transformation.

- Append-only ingestion
- Original source values preserved
- Ingestion timestamp and batch identifier
- Source reference and record checksum
- Replay support after pipeline failures
- Delta Lake storage for reliable and scalable processing

**Main tables:** `sales_raw`, `products_raw`, `stores_raw`, and `customers_raw`.

### 🥈 Silver: Clean & Historical

Silver converts raw observations into dependable business entities.

- Data types and formats are standardized
- Duplicate records are removed deterministically
- Invalid rows are rejected or quarantined
- CDC changes are applied through Delta Lake upserts
- Business rules are separated from technical cleaning
- Historical changes are preserved where business analysis requires them

**SCD Type 1:** keeps the latest corrected customer state.  
**SCD Type 2:** preserves product-price and store-location history with validity dates.

### 🥇 Gold: Business Ready

Gold exposes a dimensional model that is easy for analysts and BI tools to query.

- One central sales fact table
- Conformed product, store, customer, and date dimensions
- Surrogate keys for reliable joins
- Historical dimension resolution at the date of each sale
- Fixed-precision financial measures
- Certified definitions for revenue, cost, margin, and profitability

---

## ⭐ Gold Star Schema

<div align="center">
  <a href="walmart-star-schema-design.png">
    <img src="walmart-star-schema-design.png" alt="Walmart Gold Star Schema, metrics, quality rules, and analytical capabilities" width="100%">
  </a>
  <br>
  <sub><b>Figure 3.</b> Gold dimensional model, SCD behavior, metric definitions, quality rules, and supported analytics.</sub>
</div>

### 🧾 Fact table: `fact_sales`

The grain is **one row per unique sale identified by `sale_id`**. This explicit grain prevents mixed levels of detail and protects analytical totals against duplication.

`fact_sales` contains:

- Surrogate foreign keys for product, store, customer, and date
- `sale_id` as the transaction identifier
- `payment_method` as a descriptive sales attribute
- Quantity, revenue, discount, cost, margin, and profit-rate measures

### 🧩 Dimensions

| Dimension | Purpose | History strategy |
|---|---|---|
| `dim_products` | Describes product, category, brand, and list price | **SCD Type 2** for price and tracked business changes |
| `dim_stores` | Describes store, address, city, and region | **SCD Type 2** for location changes |
| `dim_customers` | Describes customer profile and loyalty attributes | **SCD Type 1** for current-state corrections |
| `dim_date` | Provides day, week, month, quarter, and year hierarchies | Static calendar dimension |

### 💰 Certified business metrics

- **Gross sales:** quantity multiplied by unit price
- **Net revenue:** gross sales minus discount
- **Cost amount:** quantity multiplied by unit cost
- **Gross margin:** net revenue minus cost
- **Profit rate:** gross margin divided by net revenue, protected against division by zero

Quantity and financial amounts are additive. `profit_rate` is **non-additive** and must be recalculated from aggregated margin and revenue.

### 🕰️ Historical joins

Product and store dimensions use SCD Type 2. A sale is linked to the dimension version that was valid at `sale_timestamp`, not automatically to the most recent version. Missing or late-arriving dimensions use a controlled **Unknown member** with surrogate key `-1`.

---

## 🧩 dbt Transformation Layer

The dbt project turns Silver entities into documented and testable Gold data products.

| dbt capability | Role in the project |
|---|---|
| **Staging models** | Rename, type, and standardize source fields |
| **Intermediate models** | Apply reusable technical and business logic |
| **Gold models** | Build dimensions and the sales fact table |
| **Incremental models** | Process only new or modified records |
| **Snapshots** | Preserve selected historical dimension changes |
| **Macros** | Centralize reusable calculations and rules |
| **Tests** | Prevent invalid or inconsistent data from being published |
| **Documentation** | Expose model descriptions, dependencies, and lineage |

---

## 🎛️ Airflow Orchestration

<div align="center">
  <a href="airflow-dag-workflow.png">
    <img src="airflow-dag-workflow.png" alt="Successful Apache Airflow orchestration workflow" width="100%">
  </a>
  <br>
  <sub><b>Figure 4.</b> Successful hourly Airflow execution from CDC ingestion to Gold fact publication.</sub>
</div>

### 🔄 Exact task sequence

<div align="center">

`ingest_cdc` → `clean_target` → `source_freshness` → `silver_technical` → `silver_technical_tests` → `silver_business` → `silver_business_tests` → `gold_ephemeral` → `gold_dimensions` → `gold_facts`

</div>

### What each task does

1. **`ingest_cdc`** triggers the Databricks ingestion job and waits for its final status.
2. **`clean_target`** removes previous local dbt artifacts and logs.
3. **`source_freshness`** checks whether source data is recent enough.
4. **`silver_technical`** performs typing, normalization, and technical cleaning.
5. **`silver_technical_tests`** validates the technical Silver outputs.
6. **`silver_business`** applies business rules and conformed transformations.
7. **`silver_business_tests`** validates the business-ready Silver entities.
8. **`gold_ephemeral`** prepares reusable dbt logic needed by Gold models.
9. **`gold_dimensions`** builds or snapshots analytical dimensions.
10. **`gold_facts`** publishes the final sales fact table.

### Orchestration controls

- Schedule: **hourly**
- Historical catch-up: disabled
- Automatic retries: three
- Concurrent DAG runs: limited to one
- Databricks runs: submitted and monitored remotely
- Failure behavior: downstream publication stops when a required task fails

---

## 🛡️ Data Quality & Governance

Quality controls protect every transition from raw data to certified analytics.

### Automated checks

- Unique business and surrogate keys
- Mandatory-field validation
- Accepted business values
- Dimension-to-fact relationships
- Duplicate detection
- Non-negative financial measures
- Source freshness
- Silver-to-Gold financial reconciliation
- One current SCD record per business key
- No overlapping SCD validity periods
- Invalid-record quarantine

### Governance controls

- Unity Catalog namespace: `walmart_catalog`
- Separate `bronze`, `silver`, and `gold` schemas
- Centralized permissions and ownership
- End-to-end lineage
- Batch IDs and job-run traceability
- Environment-based secret management
- Sensitive customer-data protection
- Controlled schema evolution

---

## ⚡ Engineering Decisions

| Decision | Why it matters |
|---|---|
| **Incremental CDC** | Reduces processing cost and refresh latency |
| **Delta Lake** | Provides ACID reliability for append and upsert workloads |
| **Medallion layers** | Separates raw, validated, and business-ready responsibilities |
| **Surrogate keys** | Stabilize dimensional joins and support historical versions |
| **SCD Type 2** | Makes historical product-price and store-location analysis possible |
| **dbt tests** | Detect data defects before Gold publication |
| **Airflow orchestration** | Makes dependencies, retries, and failures observable |
| **Environment variables** | Prevent credentials from being committed to GitHub |
| **`uv` dependency management** | Makes the Python environment fast and reproducible |

---

## 📊 Analytics Use Cases

The Gold model supports:

- 🏆 Store ranking by net revenue and gross margin
- 📈 Monthly trends and year-over-year growth
- 🧺 Product and category performance
- 💰 Price-change impact on demand and profitability
- 👥 Customer segmentation and loyalty analysis
- 🌍 Regional profitability
- 🚨 Store-performance anomaly detection
- 📦 Product mix and units-sold analysis

---

## 🗂️ Repository Organization

```text
walmart-lakehouse-pipeline/
├── dags/                         # Airflow orchestration
├── dbt_project/                  # dbt models, tests, macros and snapshots
├── notebooks/                    # Databricks ingestion and transformations
├── scripts/                      # Database seeding and utilities
├── config/                       # Non-sensitive configuration
├── sql/                          # DDL and analytical queries
├── tests/                        # Python tests
├── .env.example                  # Safe configuration template
├── .gitignore                    # Secret, cache and artifact exclusions
├── pyproject.toml                # Python project configuration
├── uv.lock                       # Reproducible dependencies
├── walmart-lakehouse-architecture.png
├── data-platform-overview.png
├── walmart-star-schema-design.png
├── airflow-dag-workflow.png
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.12 and `uv`
- PostgreSQL
- Databricks workspace with Unity Catalog
- Databricks SQL Warehouse or compatible compute
- dbt Core with `dbt-databricks`
- Apache Airflow

### Deployment flow

1. Clone the repository
2. Create `.env` from `.env.example`
3. Install dependencies with `uv`
4. Seed the PostgreSQL source database
5. Configure the Databricks catalog and schemas
6. Run dbt transformations and tests
7. Start Airflow
8. Enable and monitor the `orchestrate` DAG

> [!IMPORTANT]
> Never commit `.env`, Databricks tokens, passwords, or workspace secrets. Only `.env.example` should be pushed to GitHub.

---

## ✅ Production-Readiness Principles

- Idempotent processing
- Incremental workloads
- Controlled retries and timeouts
- Secure secret management
- Data contracts and tests
- Historical correctness
- Layered permissions
- Observable job executions
- Reproducible dependencies
- Recoverable pipeline stages

---

## 👤 Author

<div align="center">

### **Amine Ait Ali**

**Data Engineering Student**  
*Modern Data Stack · Lakehouse Architecture · Analytics Engineering*

This project demonstrates practical work across ingestion, distributed processing, dimensional modeling, data quality, governance, orchestration, and business analytics.

**PostgreSQL · Python · Apache Spark · Databricks · Delta Lake · dbt · Apache Airflow**

---

### ⭐ Built as a portfolio-grade reference architecture for modern retail data engineering

</div>
