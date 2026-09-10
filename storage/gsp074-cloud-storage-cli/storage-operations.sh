#!/bin/bash
export BUCKET_NAME="${GOOGLE_CLOUD_PROJECT}-bucket"

# Bucket Creation
gcloud storage buckets create gs://$BUCKET_NAME --location=us-central1

# Uploading & Copying
curl -s https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg
gcloud storage cp ada.jpg gs://$BUCKET_NAME
gcloud storage cp gs://$BUCKET_NAME/ada.jpg gs://$BUCKET_NAME/image-folder/

# ACL Management
gcloud storage objects update gs://$BUCKET_NAME/ada.jpg --add-acl-grant=entity=allUsers,role=READER
