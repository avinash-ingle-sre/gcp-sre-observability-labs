# GSP510: Manage Kubernetes in Google Cloud (Challenge Lab)

End-to-end Kubernetes platform engineering on Google Kubernetes Engine (GKE): dynamic cluster autoscaling, Google Managed Service for Prometheus (GMP), runtime log-based alerting policies, and continuous artifact deployment pipelines.

---

## 🏗️ Architecture & Operational Implementation

### 1. Dynamic Infrastructure (GKE Autoscaling)
* Provisioned multi-zone GKE cluster (`hello-world-keb8`) under `regular` release channel.
* Enabled cluster autoscaler (`min: 2`, `max: 6`, `target: 3 nodes`) to dynamically manage node capacity based on scheduling pressure.

### 2. Managed Telemetry (GMP & PodMonitoring CRD)
* Enabled Google Cloud Managed Service for Prometheus natively on the control plane.
* Configured declarative scraping targets using `PodMonitoring` Custom Resource (`monitoring.googleapis.com/v1`) scraping application endpoints on a 60-second interval without standalone Prometheus server overhead.

### 3. Incident Capture & Log-Based Alerting
* Isolated pod scheduling regressions caused by bad image tags (`InvalidImageName`).
* Implemented Cloud Logging counter metric:
  ```text
  resource.type="k8s_pod" AND severity>=WARNING



Configured Cloud Monitoring alerting policy (Pod Error Alert) with a 10-minute rolling alignment window (ALIGN_COUNT) and cross-series sum aggregation (REDUCE_SUM) triggering on threshold > 0.
4. Continuous Build & Release
Updated application core logic in main.go to release Version: 2.0.0.

Packaged container layers via Docker and authenticated via Google Cloud Artifact Registry (europe-west1-docker.pkg.dev).

Executed in-place rolling update across deployment workloads and routed traffic via an external TCP LoadBalancer on port 8080.

👤 Author
Avinash Ingle - Site Reliability Engineer
