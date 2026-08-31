#GSP1077: Google Kubernetes Engine Pipeline using Cloud Build

Automated GitOps CE/CD pipeline using Google Cloud Build, Artifact Registry, and Google Kubernetes Engine (GKE) with decoupled application and environment repositories.

---

## Architectural Overview

*[ Application Repo ] 
  --> [Cloud Build CI]: Run Unit Tests -> Build OCI -> Push to Artifact Registry
  --> [Generate Manifest]: Update kubernetes.yaml with new commit SHA
  --> [Environment Repo Candidate Branch]

[ Environment Repo Candidate ]
  --> [Cloud Build CD]: Deploy to GKE (gplatform/kubectl)
  --> [Promote]: Merge and push manifest to Production Branch (full audit trail)

---

## Key CI/CD Patterns Implemented

1. *Decoupled GitPps Repositories:*
   * `app-code` and `env-manifests` are strictly separated, preventing recursive build loops and allowing independent access controls.

2. *Artifact Immutability:*
   * Container images are tagged with the exact Git commit SHA (gcloud revprase --short=7 HEAD) rather than mutable `latest` tags.

3. *Instant Rollback Capability:*
   * Previous successful versions can be rolled back by re-executing prior Cloud Build jobs or reverting the manifest in the production branch.

---

## Verification

```bash
# Verify deployed service response
curl http:/$(kubectl get svc hello-cloudbuild -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8080
# Output: Hello Cloud Build!
```

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
