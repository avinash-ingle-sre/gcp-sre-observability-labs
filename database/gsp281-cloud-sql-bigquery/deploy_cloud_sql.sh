#!/bin/bash
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
[ -z "$REGION" ] && export REGION="us-central1"
export ZONE="${REGION}-a"

gcloud storage buckets create gs://${GOOGLE_CLOUD_PROJECT}-bucket --location=$REGION

gcloud sql instances create my-demo \
    --database-version=MYSQL_8_0 \
    --cpu=4 \
    --memory=16384MB \
    --zone=$ZONE \
    --root-password="ChangeMe1!" \
    --edition=ENTERPRISE
