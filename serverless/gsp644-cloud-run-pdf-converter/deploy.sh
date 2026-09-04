#!/bin/bash
set -e

echo "Setting region..."
export REGION=$(gcloud config get-value run/region)
[ -z "$REGION" ] && export REGION="us-east1"
gcloud config set run/region $REGION

export PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")

echo "Enabling required APIs..."
gcloud services enable run.googleapis.com pubsub.googleapis.com cloudbuild.googleapis.com

echo "Creating package.json..."


cat << 'PKGEOF' > package.json
{
  "name": "lab03",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
PKGEOF

echo "Installing npm dependencies..."
npm install express body-parser child_process @google-cloud/storage

echo "Creating Dockerfile with LibreOffice..."
cat << 'DOCKEREOF' > Dockerfile
FROM node:20
RUN apt-get update -y \
    && apt-get install -y libreoffice \
    && apt-get clean
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
DOCKEREOF

echo "Creating index.js handler..."
cat << 'INDEOF' > index.js
const { promisify } = require("util");
const { Storage } = require("@google-cloud/storage");
const exec = promisify(require("child_process").exec);
const storage = new Storage();
const express = require("express");
const bodyParser = require("body-parser");
const fs = require("fs");
const app = express();

app.use(bodyParser.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log("Listening on port", port);
});

app.post("/", async (req, res) => {
  try {
    const file = decodeBase64Json(req.body.message.data);
    await downloadFile(file.bucket, file.name);
    const pdfFileName = await convertFile(file.name);
    await uploadFile(process.env.PDF_BUCKET, pdfFileName);
    await deleteFile(file.bucket, file.name);
  } catch (ex) {
    console.log(`Error: ${ex}`);
  }
  res.set("Content-Type", "text/plain");
  res.send("\n\nOK\n\n");
});

function decodeBase64Json(data) {
  return JSON.parse(Buffer.from(data, "base64").toString());
}

async function fileExists(filePath) {
  try {
    await fs.promises.access(filePath);
    return true;
  } catch (err) {
    return false;
  }
}

async function downloadFile(bucketName, fileName) {
  const fileExistsLocally = await fileExists(`/tmp/${fileName}`);
  if (fileExistsLocally) {
    await fs.promises.unlink(`/tmp/${fileName}`);
  }
  const options = { destination: `/tmp/${fileName}` };
  await storage.bucket(bucketName).file(fileName).download(options);
}

async function convertFile(fileName) {
  const cmd = `libreoffice --headless --convert-to pdf --outdir /tmp "/tmp/${fileName}"`;
  const { stdout, stderr } = await exec(cmd);
  if (stderr) { throw stderr; }
  return fileName.replace(/\.\w+$/, ".pdf");
}

async function deleteFile(bucketName, fileName) {
  await storage.bucket(bucketName).file(fileName).delete();
}

async function uploadFile(bucketName, fileName) {
  await storage.bucket(bucketName).upload(`/tmp/${fileName}`);
}
INDEOF

echo "Building container image with Cloud Build..."
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter

echo "Deploying Cloud Run service..."
gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --memory=2Gi \
  --no-allow-unauthenticated \
  --max-instances=1 \
  --set-env-vars PDF_BUCKET=$GOOGLE_CLOUD_PROJECT-processed

export SERVICE_URL=$(gcloud run services describe pdf-converter --region $REGION --format="value(status.url)")

echo "Creating Cloud Storage buckets..."
gcloud storage buckets create gs://$GOOGLE_CLOUD_PROJECT-upload || true
gcloud storage buckets create gs://$GOOGLE_CLOUD_PROJECT-processed || true

echo "Setting up Pub/Sub notifications..."
gcloud storage buckets notifications create -t new-doc -f json -e OBJECT_FINALIZE gs://$GOOGLE_CLOUD_PROJECT-upload || true

echo "Configuring IAM service accounts..."
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker" || true

gcloud run services add-iam-policy-binding pdf-converter \
  --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --region $REGION

gcloud beta services identity create --service=pubsub.googleapis.com --project="$GOOGLE_CLOUD_PROJECT" || true

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator || true

gcloud pubsub subscriptions create pdf-conv-sub \
  --topic new-doc \
  --push-endpoint=$SERVICE_URL \
  --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com || true

echo "Deployment and configuration completed successfully."
