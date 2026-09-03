# GSP497: Kubernetes Engine Monitoring with Terraform

Automated deployment, Prometheus alert integration, and lifecycle teardown of a Google Kubernetes Engine (GKE) cluster using Terraform.

---

## 🚀 🔍 **Architectural Overview** 🏆

1. **IaC Deployment:** Deployed declarative infrastructure using Terraform and Make targets (`make create`, `make teardown`).
2. **Cloud Shell Bug Remediation:** Resolved missing `terraform` binary in Google Cloud Shell environment dynamically via HashiCorp repository configuration.
3. **Telemetry & Prometheus Alerting:** Provisioned GKE cluster (`stackdriver-monitoring-tutorial`) in `europe-west1-d` with native metric ingestion from pod-level Prometheus endpoints (`mem alloc above 12`).
4. **Zero-Footprint Lifecycle:** Decommissioned all 5 provisioned cloud assets cleanly via automated `make teardown` to enforce cost-effective SRE practices.

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
EOF
