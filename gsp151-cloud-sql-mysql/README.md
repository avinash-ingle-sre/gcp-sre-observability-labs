#GSP151: Cloud SQL for MySQL: Qwik Start

Deploying MySQL 8 Enterprise Edition on Google Cloud SQL.

---

## 🚠 🔎 **Architectural Overview** 🏅

1. **Cloud SQL Instance:** Provisioned a MySQL 8 instance (`myinstance`) using Compute Custom Tier (4 vCPU, ~16GB RAM) in `asia-south1`.
2. **Database & Schema:** Created `guestbook` database, connected via Cloud Shell, and inserted sample records.
3. **Idempotent setup:** Used bash script to automate instance provisioning and DB creation with built-in delays.

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
