#!/bin/bash
set -e

echo "=== 1. Setup Environment ==="
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
[ -z "$REGION" ] && export REGION="us-east1"

gcloud config set run/region $REGION
gcloud config set run/platform managed
gcloud services enable run.googleapis.com cloudbuild.googleapis.com

export PROJECT_ID=$GOOGLE_CLOUD_PROJECT

cd /tmp
rm -rf pet-theory
git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab07

echo "=== 2. Task 1: Deploy Public Billing Service ==="
cd /tmp/pet-theory/lab07/unit-api-billing
gcloud builds submit --tag gcr.io/$PROJECT_ID/billing-staging-api:0.1
gcloud run deploy public-billing-service-488 \
  --image gcr.io/$PROJECT_ID/billing-staging-api:0.1 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --quiet

echo "=== 3. Task 2: Deploy Frontend Staging Service ==="
cd /tmp/pet-theory/lab07/staging-frontend-billing
gcloud builds submit --tag gcr.io/$PROJECT_ID/frontend-staging:0.1
gcloud run deploy frontend-staging-service-443 \
  --image gcr.io/$PROJECT_ID/frontend-staging:0.1 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --quiet

echo "=== 4. Task 3: Deploy Private Billing Service ==="
gcloud run services delete public-billing-service-488 --platform managed --region $REGION --quiet || true

cd /tmp/pet-theory/lab07/staging-api-billing
gcloud builds submit --tag gcr.io/$PROJECT_ID/billing-staging-api:0.2
gcloud run deploy private-billing-service-312 \
  --image gcr.io/$PROJECT_ID/billing-staging-api:0.2 \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --quiet

export BILLING_URL=$(gcloud run services describe private-billing-service-312 --platform managed --region $REGION --format "value(status.url)")
curl -X GET -H "Authorization: Bearer $(gcloud auth print-identity-token)" $BILLING_URL

echo "=== 5. Task 4 & 5: Billing Service Account & Prod Billing Service ==="
gcloud iam service-accounts create billing-service-sa-193 \
  --display-name "Billing Service Cloud Run" || true

cd /tmp/pet-theory/lab07/prod-api-billing
gcloud builds submit --tag gcr.io/$PROJECT_ID/billing-prod-api:0.1
gcloud run deploy billing-prod-service-376 \
  --image gcr.io/$PROJECT_ID/billing-prod-api:0.1 \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --service-account billing-service-sa-193@$PROJECT_ID.iam.gserviceaccount.com \
  --quiet

export PROD_BILLING_URL=$(gcloud run services describe billing-prod-service-376 --platform managed --region $REGION --format "value(status.url)")
curl -X GET -H "Authorization: Bearer $(gcloud auth print-identity-token)" $PROD_BILLING_URL

echo "=== 6. Task 6 & 7: Frontend Invoker SA & Prod Frontend Service ==="
gcloud iam service-accounts create frontend-service-sa-716 \
  --display-name "Billing Service Cloud Run Invoker" || true

gcloud run services add-iam-policy-binding billing-prod-service-376 \
  --member=serviceAccount:frontend-service-sa-716@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --platform managed \
  --region $REGION

cd /tmp/pet-theory/lab07/prod-frontend-billing
gcloud builds submit --tag gcr.io/$PROJECT_ID/frontend-prod:0.1
gcloud run deploy frontend-prod-service-458 \
  --image gcr.io/$PROJECT_ID/frontend-prod:0.1 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --service-account frontend-service-sa-716@$PROJECT_ID.iam.gserviceaccount.com \
  --quiet

export PROD_FRONTEND_URL=$(gcloud run services describe frontend-prod-service-458 --platform managed --region $REGION --format "value(status.url)")
curl -I $PROD_FRONTEND_URL

echo "=== Deployment Pipeline Complete ==="
