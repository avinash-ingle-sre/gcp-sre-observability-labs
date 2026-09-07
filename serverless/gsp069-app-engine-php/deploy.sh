#!/bin/bash
set -e

export REGION="us-east4"
gcloud config set compute/region $REGION

echo "Enabling App Engine Admin API..."
gcloud services enable appengine.googleapis.com

echo "Deploying PHP Application to App Engine Standard..."
gcloud app deploy --quiet

echo "Deployment completed successfully. Application URL:"
gcloud app browse
