# GSP053: Managing Kubernetes Deployments on GKE

Production-grade deployment patterns on Google Kubernetes Engine (GKE): Rolling Updates, Canary Deployments, and Blue-Green Traffic Shifting.

---

## 📂 Structure
* `deployments/` - Kubernetes Deployment manifests for blue, green, and canary workloads.
* `services/` - Kubernetes Service manifests for routing traffic.

---

## 🎯 Key Learnings & Verification

### 1. Rolling Update & In-Flight Control
* Executed image updates from `1.0.0` to `2.0.0`.
* Paused in-flight rollouts (`kubectl rollout pause`) to inspect hybrid state.
* Instantly rolled back breaking versions (`kubectl rollout undo`).

### 2. Native Canary Deployment
* Routed external traffic across two independent Deployments (`blue` and `canary`) using a shared Service selector (`app: fortune-app`).
* Achieved ~25% traffic weighting to the canary instance natively via replica counts (3:1).

### 3. Blue-Green Cutover
* Maintained parallel isolated environments (`blue` and `green`).
* Shifted 100% of live traffic by updating the Service label selector (`version: 2.0.0`) with zero dropped connections.

---

## 👤 Author
* **Avinash Ingle** - *Site Reliability Engineer*
