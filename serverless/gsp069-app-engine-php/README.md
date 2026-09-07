# GSP069: App Engine: Qwik Start - PHP

## Overview
This lab demonstrates provisioning and updating a containerized PHP application on **Google App Engine Standard Environment** in region `us-east4`.

## Architecture Details
- **Runtime:** `php83` (PHP 8.3 standard runtime).
- **Service Tier:** Automatic scaling configured with instance tier `F1`.
- **Deployment Mechanics:** Direct source bundle upload to Google Cloud Storage handled by `gcloud app deploy`.
- **Platform:** Fully managed serverless PaaS with zero infrastructure overhead.

## Deployment Automation
Deploy the service using:
```bash
./deploy.sh
