#!/bin/bash
set -e

export REGION="us-central1"
gcloud config set compute/region $REGION

echo "Enabling App Engine Admin API..."
gcloud services enable appengine.googleapis.com

echo "Installing Google Cloud SDK App Engine Go component..."
sudo apt-get update -y
sudo apt-get install -y google-cloud-sdk-app-engine-go

echo "Creating App Engine application if not exists..."
gcloud app create --region=us-central 2>/dev/null || true

echo "Deploying Go application to App Engine Standard..."
gcloud app deploy --quiet

echo "Deployment complete. App URL:"
gcloud app browse
