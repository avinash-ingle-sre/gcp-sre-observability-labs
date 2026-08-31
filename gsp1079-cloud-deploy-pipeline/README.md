#GSP1079: Google Cloud Deploy Delivery Pipeline

Automated multi-environment promotion sequence (Test -> Staging -> Production) using Google Cloud Deploy, Skaffold, Artifact Registry, and GKE.

---

## Architecture and Delivery Overview

*[ Skaffold Build ] -> Push to Artifact Registry with Immutable Digests
[ Cloud Deploy Release ] -> Render manifests once (Point-in-time audit)
  |--> Target 1: Test GKE (Inmediate Rollout)
  |--> Target 2: Staging GKE (Promotion Gate)
  |--> Target 3: Prod GKE (Mandatory Approval Required)

---

## Key CD Patterns Implemented

1. *Render-Once, Deploy-Many Principle:*
   * Manifests are rendered exactly once during release creation; the exact same sha256 digest is promoted across all targets without mutation.

2. *Governance via Manual Approval Gates:*
   * Production target enforces `requireApproval: true`, preventing unauthorized code execution until formal approval is granted.

3. *Decoupled Target Configuration:*
   * Targets define cluster locations independently from application manifests, making multi-cluster and multi-region promotion seamless.

---

## Verification Runbook

```bash
# Create Release
gcloud beta deploy releases create web-app-001 --delivery-pipeline=web-app --build-artifacts=web/artifacts.json --source=web/

# Promote to Staging
gcloud beta deploy releases promote --delivery-pipeline=web-app --release=web-app-001 --quiet

# Promote to Prod and Approve
gcloud beta deploy releases promote --delivery-pipeline=web-app --release=web-app-001 --quiet
gcloud beta deploy rollouts approve web-app-001-to-prod-0001 --delivery-pipeline=web-app --release=web-app-001 --quiet
```

---

## Author
* **Avinash Ingle** - Site Reliability Engineer
