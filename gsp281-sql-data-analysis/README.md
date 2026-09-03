# GSP281: SQL for Data Analysis - Quick Start

Automated the extraction of insights from structured datasets using BigQuery and provisioned relational database infrastructure using Cloud SQL.

---

## 🚀 🔍 **Architectural Overview** 🏆

1. **BigQuery Data Extraction:** 
   - Queried `bigquery-public-data.london_bicycles.cycle_hire` processing petabyte-scale data.
   - Utilized SQL keywords (`SELECT`, `GROUP BY`, `COUNT`, `ORDER BY DESC`) to aggregate over 83 million records into summary statistics.
2. **Cloud Storage Staging:** 
   - Exported query results directly to local CSVs and uploaded them to a newly provisioned Cloud Storage bucket (`gs://$PROJECT_ID`) for staging.
3. **Cloud SQL Infrastructure Provisioning:** 
   - Deployed a highly available (Multi-zone/Regional) MySQL 8.0 Enterprise instance (`my-demo`) using `db-custom-4-16384` tier via `gcloud`.
   - Provisioned the internal `bike` database ready for structured table ingestion.

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
