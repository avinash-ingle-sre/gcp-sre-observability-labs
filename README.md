# Google Cloud Platform: SRE & Observability Engineering Labs

A structured portfolio of production-grade Google Cloud Platform (GCP) and Google Kubernetes Engine (GKE) implementations, covering Site Reliability Engineering (SRE) patterns, system observability, and deployment strategies.

---

## 📂 Laboratory Catalog

| Directory | Topic & Workload | Architecture & Tools |
| :--- | :--- | :--- |
| **`gsp053-k8s-deployment-strategies/`** | Advanced K8s Deployments | Rolling Updates, Ratio Canary, Blue-Green Traffic Switch |
| **`gsp736-debug-apps-gke/`** | Microservices Incident RCA | Cloud Logging, Cloud Monitoring, Log-based SLI, Concurrency Debugging |
| **`gsp1026-managed-prometheus/`** | Hybrid Telemetry Pipelines | Google Managed Service for Prometheus (GMP), PodMonitoring CRDs, Node Exporter |

---

## 🎯 Engineering Standards
* **Declarative Configurations:** All deployments configured strictly via Kubernetes manifests.
* **Isolated Branches:** Each laboratory implementation is developed on dedicated feature branches (`lab/<gsp-id>-<short-name>`) and merged via Pull Requests.
* **Granular Documentation:** Every individual lab contains an isolated execution runbook, architectural breakdown, and verification outputs.

---

## 👤 Maintainer
**Avinash Ingle**  
*Site Reliability & Cloud Operations Engineer*
