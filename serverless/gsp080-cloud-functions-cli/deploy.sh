#!/bin/bash
set -e
export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud functions deploy nodejs-pubsub-function \
  --gen2 \
  --runtime=nodejs20 \
  --region=$REGION \
  --source=. \
  --entry-point=helloPubSub \
  --trigger-topic cf-demo \
  --stage-bucket ${PROJECT_ID}-bucket \
  --service-account cloudfunctionsa@${PROJECT_ID}.iam.gserviceaccount.com \
  --allow-unauthenticated \
  --quiet
