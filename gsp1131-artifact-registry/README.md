# GSP1131: Getting Started with Artifact Registry

Enterprise container registry management on Google Cloud Platform: private repository provisioning, credential helper integration, and OCI image push/pull workflows.

---

## Architecture and Operations Summary

### 1. Private Regional OCI Repository
* Provisioned standard Docker registry (`example-docker-repo`) located in `us-central1`.
* Configured native IAM governance and regional isolation.

### 2. Ephemeral Authentication
* Configured Docker daemon integration via `gcloud auth configure-docker us-central1-docker.pkg.dev`.
* Leveraged short-lived OAuth access tokens instead of static service account keys.

### 3. Image Tagging and Promotion
* Tagged base layer workloads adhering to GCP container registry naming conventions:
  `us-central1-docker.pkg.dev/$PROJECT_ID/example-docker-repo/sample-image:tag1`
* Validated remote push and image ingestion pipeline.

---

## Verification Runbook

### Step 1: Configure Docker Authentication
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

### Step 2: Tag Local Container Image
docker tag hello-app:1.0 us-central1-docker.pkg.dev/$PROJECT_ID/example-docker-repo/sample-image:tag1

### Step 3: Push Artifact to Registry
docker push us-central1-docker.pkg.dev/$PROJECT_ID/example-docker-repo/sample-image:tag1

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
