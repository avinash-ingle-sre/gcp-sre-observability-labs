#!/bin/bash
set -e

export REGION="asia-southeast1"
export ZONE="asia-southeast1-c"

gcloud config set compute/region $‘REGION
gcloud config set compute/zone $ZONE

for i in 1 2 3; do
  cat << STARTUP_EOF > startup$i.sh
#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "</h3>Web Server: web$i</h3>" | tee /var/www/html/index.html
STARTUP_EOF

  gcloud compute instances create web$i \
    --zone=$zONE \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata-from-file startup-script=startup$i.sh
done

gcloud compute firewall-rules create www-firewall-network-lb \
    --network=default \
    --target-tags=network-lb-tag \
    --allow=tcp:80 2>/dev/null || true

gcloud compute addresses create network-lb-ip-1 --region=$REGION
gcloud compute http-health-checks create basic-check

gcloud compute target-pools create www-pool \
    --region=$REGION \
    --http-health-check=basic-check

gcloud compute target-pools add-instances www-pool \
    --instances=web1,web2,web3 \
    --instances-zone=$ZONE

gcloud compute forwarding-rules create www-rule \
    --region=$REGION \
    --ports=80 \
    --address=network-lb-ip-1 \
    --target-pool=www-pool

cat << 'LB_STARTUP' > lb_startup.sh
#!/bin/bash
apt-get update
apt-get install apache2 -y
a2ensite default-ssl
a2enmod ssl
vm_hostname="$(curl -H "Metadata-Flavor:Google" http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "Page served from: $vm_hostname" | tee /var/www/html/index.html
systemctl restart apache2
LB_STARTUP

gcloud compute instance-templates create lb-backend-template \
   --region=$REGION \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-12 \
   --image-project=debian-cloud \
   --metadata-from-file startup-script=lb_startup.sh

gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template \
   --size=2 \
   --zone=$ZONE

gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80

gcloud compute addresses create lb-ipv4-1 --ip-version=IPV4 --global
gcloud compute health-checks create http http-basic-check --port=80

gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global

gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=$ZONE \
  --global

gcloud compute url-maps create web-map-http --default-service=web-backend-service
gcloud compute target-http-proxies create http-lb-proxy --url-map=web-map-http
gcloud compute forwarding-rules create http-content-rule \
   --address=lb-ipv4-1 \
   --global \
   --target-http-proxy=http-lb-proxy \
   --ports=80
