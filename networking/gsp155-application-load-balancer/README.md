# GSP155: Set Up an Application Load Balancer on Google Cloud

## Overview
This implementation demonstrates setting up an external HTTP Layer 7 (L7) Application Load Balancer using Google Front Ends (GFEs) and Compute Engine managed instance groups (MIG).

## Infrastructure Stack
* **Cloud Platform:** Google Cloud Platform (GCP)
* **Compute Engine:** Managed Instance Group (MIG) with autoscaling templates running Apache2
* **Networking & Traffic:**
  * Global External HTTP(S) Load Balancer
  * Global IPv4 Frontend Forwarding Rule
  * URL Maps & Target HTTP Proxies
  * Port 80 HTTP Health Checks (`http-basic-check`)
  * Health-check Ingress Firewall Rules (`130.211.0.0/22`, `35.191.0.0/16`)

## Deployment Script
The complete automated provisioning script is located in `deploy.sh`.
