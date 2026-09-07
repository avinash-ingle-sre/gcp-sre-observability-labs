#!/bin/bash
set -e
export REGION="us-west1"
gcloud app create --region=$REGION 2>/dev/null || true
gcloud app deploy --quiet
