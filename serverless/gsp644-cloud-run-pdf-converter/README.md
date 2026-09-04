# GSP644: Build a Serverless App with Cloud Run that Creates PDF Files

## Overview
This project implements a serverless event-driven PDF conversion pipeline for Pet Theory veterinary clinic invoices using Google Cloud services.

## Architecture & Components
- **Google Cloud Storage:** 
  - `[PROJECT-ID]-upload`: Staging bucket where source documents (DOCX, images, etc.) are uploaded.
  - `[PROJECT-ID]-processed`: Destination bucket where converted PDF files are stored.
- **Cloud Pub/Sub:** Event notification topic (`new-doc`) triggered on `OBJECT_FINALIZE` events from the upload bucket, linked via push subscription (`pdf-conv-sub`).
- **Cloud Run:** Serverless containerized Node.js service (`pdf-converter`) provisioned with **LibreOffice** and 2GB RAM to handle headless document conversion.
- **IAM Security:** Authenticated service accounts (`pubsub-cloud-run-invoker`) enforcing secure, zero-trust serverless triggers.

## Automation Script
The complete end-to-end provisioning and deployment pipeline is codified in `deploy.sh`.
