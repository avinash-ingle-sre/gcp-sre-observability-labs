# GSP072: BigQuery Qwik Start

Automated the provisioning of BigQuery datasets, loading of external data from Google Cloud Storage, and execution of analytics queries using the `bq` CLI.

---

## 🚀 🔍 **Architectural Overview** 🏆

1. **Dataset Management:** Provisioned a new BigQuery dataset (`babynames`) programmatically using `bq mk`.
2. **Data Loading:** Ingested CSV data directly from a Cloud Storage bucket (`gs://spls/gsp072/baby-names/yob2014.txt`) into a new table (`names_2014`) while explicitly defining the schema (`name:string,gender:string,count:integer`) using `bq load`.
3. **Query Execution:** Executed Standard SQL queries against both massive public datasets (`bigquery-public-data.samples.natality`) and custom datasets to filter, aggregate, and order records, utilizing `bq query`.

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
EOF
