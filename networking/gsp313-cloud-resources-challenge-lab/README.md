# GSP313: Create and Manage Cloud Resources - Challenge Lab

## Overview
This directory contains the complete automation and infrastructure configuration for the GSP313 Challenge Lab on Google Cloud Platform (GCP).

## Infrastructure Stack
- Target Region: `asia-southeast1`
- Target Zone: `asia-southeast1-c`

---

## Tasks Completed

### Task 1: Multiple Web Server Instances
- 3 Compute Engine virtual machines provisioned: `web1`, `web2`, `web3` (`e2-small`, Debian 12).
- Automatic Apache2 web server installation via startup scripts.
- Firewall Rule: `www-firewall-network-lb` allowing TCP port 80 traffic to tag `network-lb-tag`.

### Task 2: Network Load Balancing Service (Layer 4)
- Regional reserved IPv4 address: `network-lb-ip-1`.
- Http Health Check: `basic-check`.
- Target Pool: `www-pool` containing `web1`, `web2`, and `web3`.
- Forwarding Rule: `www-rule` listening on Port 80 routing to the target pool.

### Task 3: HTTP Application Load Balancer (Layer 7)
- Instance Template: `lb-backend-template` (`e2-medium`) with SSL and dynamic hostname metadata checks.
- Managed Instance Group (MIG): `lb-backend-group` (size: 2).
- Ingress Health-Check Firewall: `fw-allow-health-check` for `130.211.0.0/22` and `35.191.0.0/16`.
- Global IPv4: `lb-ipv4-1`.
- Health Check: `http-basic-check` (Port 80).
- Backend Service: `web-backend-service` attached to MIG.
- Routing: URL Map `web-map-http`, HTTP Proxy `http-lb-proxy`, and Global Forwarding Rule `http-content-rule` on Port 80.

---

## Deployment
- Execute the automated shell script:
  ``@bash
  ./deploy.sh
  ``a
