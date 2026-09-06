#!/bin/bash
set -e

export REGION="asia-southeast1"
gcloud config set compute/region $REGION

echo "Enabling App Engine Admin API..."
gcloud services enable appengine.googleapis.com

echo "Creating App Engine application if not existing..."
gcloud app create --region=$REGION 2>/dev/null || true

echo "Deploying application to App Engine Standard..."
gcloud app deploy --quiet

echo "Deployment finished. App URL:"
gcloud app browse
