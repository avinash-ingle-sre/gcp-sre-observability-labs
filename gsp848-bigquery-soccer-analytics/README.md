# GSP848: Ingesting and Querying Sports Data in BigQuery

Automated ingestion of multi-format sports telemetry data (JSONL, CSV) from Google Cloud Storage into Google BigQuery using the `bq` CLI tool.

---

## 🚀 🔍 **Architectural Overview** 🏆

1. **Dataset Creation:** Provisioned multi-region `soccer` dataset in BigQuery.
2. **Schema Auto-detection:** Ingested semi-structured data (`competitions`, `matches`, `teams`, `players`, `events`) using JSONL and structured CSV data (`tags2name`) leveraging BigQuery's schema auto-discovery.
3. **Data Analytics Queries:** 
   - Analyzed physical traits of soccer positions using string concatenation and filtering (`role.name = 'Defender'`).
   - Grouped and aggregated over 3.2M event telemetry records using `COUNT()` and `GROUP BY`.

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
