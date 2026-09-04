# GSP650: Develop a Serverless Event-Driven Solution with Google Cloud Run & Pub/Sub

## Architecture Overview
This lab implements an asynchronous, resilient, and decoupled microservices architecture for Pet Theory using Google Cloud Serverless primitives:
- **Lab Report Service:** Public-facing HTTPS ingestion service deployed on Cloud Run that receives medical test reports and publishes JSON payloads to Cloud Pub/Sub.
- **Cloud Pub/Sub Topic:** `new-lab-report` acting as the central message bus decoupling publishers from consumers.
- **Email Service & SMS Service:** Downstream consumer services deployed on Cloud Run triggered asynchronously via authenticated Pub/Sub push subscriptions (`email-service-sub` and `sms-service-sub`).
- **Resilience Model:** Demonstrates exponential backoff retries and fault isolation (e.g., downstream email failure triggers 500 response leading to automated Pub/Sub retries without impacting SMS notifications).

## Security & IAM
- Authenticated invocation enforced using dedicated IAM Service Account (`pubsub-cloud-run-invoker`) with `roles/run.invoker`.
- Token creation rights granted to Pub/Sub system identity using `roles/iam.serviceAccountTokenCreator`.

## Automation
The entire infrastructure, service deployment, and subscription linkage is automated in `deploy.sh`.
