# GSP067: App Engine: Qwik Start - Python

## Architecture & Overview
This lab provisions a serverless web application using **Google App Engine Standard Environment** deployed in `asia-southeast1`.

- **Platform:** Google App Engine (Standard Environment, Python 3.9 runtime).
- **Compute Model:** Fully managed PaaS. Automatic horizontal scaling (scales down to 0 instances when idle to eliminate runtime cost).
- **Application Framework:** Flask microframework served via Gunicorn.
- **Service Configuration:** Defined via `app.yaml` using `F1` automatic scaling tiers.

## Deployment Instructions
Run the automated deployment script directly via Cloud Shell:
```bash
./deploy.sh
