# GSP071: BigQuery Qwik Start - Command Line

Automated the execution of data analytics and infrastructure lifecycle tasks in BigQuery exclusively using the `bq`CLI tool.

---

## ğŸš€ ğŸ” **Architectural Overview** ğ‡†

1. **CLI Analytics:** Queried massive public datasets (`bigquery-public-data.samples.shakespeare`) using `bq query` and Standard SQL to search for substrings and count occurrences.
2. **Infrastructure Provisioning:** Created a dataset (`babynames`) using `bq mk`.
3. **Data Ingestion:** Downloaded flat files (ZIP/TXT) directly into Cloud Shell and loaded them into a BigQuery table (`names2010`) using `bq load` with an explicit schema definition.
4. **Lifecycle Teardown:** Performed a clean teardown of the dataset and associated tables using `bq rm -r -f` to maintain a zero-footprint environment.

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
