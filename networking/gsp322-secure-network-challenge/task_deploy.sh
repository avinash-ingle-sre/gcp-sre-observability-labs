#!/bin/bash
set -e

# १. दुरुस्त केलेले टॅग्स (कंस काढून टाकले आहेत)
export IAP_TAG="grant-ssh-iap-ingress-ql-323"
export HTTP_TAG="grant-http-ingress-ql-323"
export INTERNAL_SSH_TAG="grant-ssh-internal-ingress-ql-323"

# २. झोन आणि नेटवर्क माहिती डायनॅमिकली मिळवणे
export ZONE=$(gcloud compute instances list --filter="name=bastion" --format="value(zone)")
export REGION=${ZONE%-*}
export NETWORK=$(gcloud compute instances describe bastion --zone=$ZONE --format="value(networkInterfaces[0].network)")
export MGMT_SUBNET_CIDR=$(gcloud compute networks subnets describe acme-mgmt-subnet --region=$REGION --format="value(ipCidrRange)")

echo "=== टास्क १: Remove the overly permissive rules ==="
gcloud compute firewall-rules delete open-access --quiet || true
echo "Deleted overly permissive rule: open-access"

echo "=== टास्क २: Start the bastion host instance ==="
gcloud compute instances start bastion --zone=$ZONE

echo "=== टास्क ३: IAP SSH रूल बनवणे आणि Bastion ला टॅग लावणे ==="
gcloud compute firewall-rules create allow-ssh-iap \
    --network=$NETWORK \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=$IAP_TAG

gcloud compute instances add-tags bastion --tags=$IAP_TAG --zone=$ZONE

echo "=== टास्क ४: HTTP रूल बनवणे ==="
gcloud compute firewall-rules create allow-http-juice-shop \
    --network=$NETWORK \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=$HTTP_TAG

echo "=== टास्क ५: Internal SSH रूल बनवणे ==="
gcloud compute firewall-rules create allow-ssh-internal \
    --network=$NETWORK \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=$MGMT_SUBNET_CIDR \
    --target-tags=$INTERNAL_SSH_TAG

echo "=== टास्क ६: Juice-shop इन्स्टन्सला टॅग्स लावणे ==="
gcloud compute instances add-tags juice-shop --tags=$HTTP_TAG,$INTERNAL_SSH_TAG --zone=$ZONE
