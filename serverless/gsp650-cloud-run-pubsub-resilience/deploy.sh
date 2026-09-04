#!/bin/bash
set -e

echo "=== 1. Environment & API Setup ==="
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
[ -z "$REGION" ] && export REGION="us-central1"

gcloud config set run/region $REGION
gcloud services enable run.googleapis.com pubsub.googleapis.com cloudbuild.googleapis.com

export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# Pub/Sub Topic
gcloud pubsub topics create new-lab-report || true

# Clone Application Source Code
cd /tmp
rm -rf pet-theory
git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab05

echo "=== 2. Deploy Lab Report Service ==="
cd /tmp/pet-theory/lab05/lab-service

cat << 'PKG' > package.json
{
  "name": "lab-service",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "@google-cloud/pubsub": "^4.0.0",
    "body-parser": "^1.20.2",
    "express": "^4.19.2"
  }
}
PKG

cat << 'INDEX' > index.js
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const express = require('express');
const app = express();
const bodyParser = require('body-parser');

app.use(bodyParser.json());
const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log('Listening on port', port);
});

app.post('/', async (req, res) => {
  try {
    const labReport = req.body;
    await publishPubSubMessage(labReport);
    res.status(204).send();
  }
  catch (ex) {
    console.log(ex);
    res.status(500).send(ex);
  }
});

async function publishPubSubMessage(labReport) {
  const buffer = Buffer.from(JSON.stringify(labReport));
  await pubsub.topic('new-lab-report').publish(buffer);
}
INDEX

cat << 'DOCKER' > Dockerfile
FROM node:20-slim
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
DOCKER

gcloud builds submit --tag gcr.io/$PROJECT_ID/lab-report-service
gcloud run deploy lab-report-service \
  --image gcr.io/$PROJECT_ID/lab-report-service \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances=1

echo "=== 3. Deploy Email Service ==="
cd /tmp/pet-theory/lab05/email-service

cat << 'PKG' > package.json
{
  "name": "email-service",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "body-parser": "^1.20.2",
    "express": "^4.19.2"
  }
}
PKG

cat << 'INDEX' > index.js
const express = require('express');
const app = express();
const bodyParser = require('body-parser');

app.use(bodyParser.json());
const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log('Listening on port', port);
});

app.post('/', async (req, res) => {
  const labReport = decodeBase64Json(req.body.message.data);
  try {
    console.log(`Email Service: Report ${labReport.id} trying...`);
    sendEmail();
    console.log(`Email Service: Report ${labReport.id} success :-)`);
    res.status(204).send();
  }
  catch (ex) {
    console.log(`Email Service: Report ${labReport.id} failure: ${ex}`);
    res.status(500).send();
  }
});

function decodeBase64Json(data) {
  return JSON.parse(Buffer.from(data, 'base64').toString());
}

function sendEmail() {
  console.log('Sending email');
}
INDEX

cat << 'DOCKER' > Dockerfile
FROM node:20-slim
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
DOCKER

gcloud builds submit --tag gcr.io/$PROJECT_ID/email-service
gcloud run deploy email-service \
  --image gcr.io/$PROJECT_ID/email-service \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --max-instances=1

# IAM Service Account & Role Bindings
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker" || true

gcloud run services add-iam-policy-binding email-service \
  --member=serviceAccount:pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --region $REGION \
  --platform managed

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator || true

export EMAIL_SERVICE_URL=$(gcloud run services describe email-service --platform managed --region $REGION --format="value(status.address.url)")

gcloud pubsub subscriptions create email-service-sub \
  --topic new-lab-report \
  --push-endpoint=$EMAIL_SERVICE_URL \
  --push-auth-service-account=pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com || true

echo "=== 4. Deploy SMS Service ==="
cd /tmp/pet-theory/lab05/sms-service

cat << 'PKG' > package.json
{
  "name": "sms-service",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "body-parser": "^1.20.2",
    "express": "^4.19.2"
  }
}
PKG

cat << 'INDEX' > index.js
const express = require('express');
const app = express();
const bodyParser = require('body-parser');

app.use(bodyParser.json());
const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log('Listening on port', port);
});

app.post('/', async (req, res) => {
  const labReport = decodeBase64Json(req.body.message.data);
  try {
    console.log(`SMS Service: Report ${labReport.id} trying...`);
    sendSms();
    console.log(`SMS Service: Report ${labReport.id} success :-)`);
    res.status(204).send();
  }
  catch (ex) {
    console.log(`SMS Service: Report ${labReport.id} failure: ${ex}`);
    res.status(500).send();
  }
});

function decodeBase64Json(data) {
  return JSON.parse(Buffer.from(data, 'base64').toString());
}

function sendSms() {
  console.log('Sending SMS');
}
INDEX

cat << 'DOCKER' > Dockerfile
FROM node:20-slim
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
DOCKER

gcloud builds submit --tag gcr.io/$PROJECT_ID/sms-service
gcloud run deploy sms-service \
  --image gcr.io/$PROJECT_ID/sms-service \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --max-instances=1

gcloud run services add-iam-policy-binding sms-service \
  --member=serviceAccount:pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --region $REGION \
  --platform managed

export SMS_SERVICE_URL=$(gcloud run services describe sms-service --platform managed --region $REGION --format="value(status.address.url)")

gcloud pubsub subscriptions create sms-service-sub \
  --topic new-lab-report \
  --push-endpoint=$SMS_SERVICE_URL \
  --push-auth-service-account=pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com || true

echo "=== Deployment Pipeline Complete ==="
