# GSP070: App Engine: Qwik Start - Go

## Overview
This directory contains the deployment automation and source artifacts for deploying a Golang web service to **Google App Engine Standard Environment** in region `us-central`.

## Architecture Details
- **Service Platform:** Google App Engine (Standard Environment).
- **Runtime:** `go111` (Go 1.11 sandbox environment).
- **Scaling:** Managed automatic horizontal scaling via App Engine frontends.
- **Traffic Routing:** Served securely via Google-managed HTTPS endpoint.

## Deployment
Execute the automated shell script:
```bash
./deploy.sh
