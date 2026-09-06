# GSP328: Develop Serverless Applications on Cloud Run - Challenge Lab

## Architecture & Overview
This challenge lab transforms a monolithic veterinary billing application into a scalable, secure, and resilient microservices architecture on **Google Cloud Run**.

### Staging Environment
- **Public Billing API (`public-billing-service-488`):** Initial unauthenticated prototype built with `billing-staging-api:0.1`.
- **Frontend Staging (`frontend-staging-service-443`):** Public frontend interface built with `frontend-staging:0.1`.
- **Private Billing API (`private-billing-service-312`):** Updated private service with `billing-staging-api:0.2` requiring Google IAM identity token authorization.

### Production Architecture & Security Model
- **Billing Service (`billing-prod-service-376`):**
  - Container Image: `gcr.io/[PROJECT_ID]/billing-prod-api:0.1`
  - Authentication: Authenticated invocation only (`--no-allow-unauthenticated`).
  - Runtime Identity: Attached to dedicated service account `billing-service-sa-193`.
- **Frontend Service (`frontend-prod-service-458`):**
  - Container Image: `gcr.io/[PROJECT_ID]/frontend-prod:0.1`
  - Authentication: Unauthenticated public access.
  - Identity & IAM: Bound to `frontend-service-sa-716` which holds `roles/run.invoker` permissions to securely call the private billing backend.

## Automation Script
The full reproduction script with explicit IAM policy bindings, container builds, and deployment commands is provided in `deploy.sh`.
