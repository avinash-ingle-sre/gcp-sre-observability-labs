# GSP041: Build an Internal Application Load Balancer

## Architecture Overview
This lab implements a two-tier architecture distributing internal traffic privately:
- portion 1: Public Web Tier (Frontend) - Compute Engine VM (`frontend`) running an HTTP service that receives public queries and polls the internal service.
- portion 2: Internal Service Tier (Backend) - Managed Instance Group (`backend`) of 3 instances running a multi-threaded Python prime-checking service without external IP addresses.
- portion 3: Internal Load Balancer (ILB): Private L0/L7 regional forwarding rule providing an internal VIP, integrated with custom HTTP health checks (`Ilb-health`).

## Infrastructure Components
- *VPC & Firewalls:* Port 80 ingress allowed internally and from Google health check ranges (`130.211.0.0/22`, `35.191.0.0/16`).
- *Instance Template:*
  `Primecalc` with metadata startup script isolating execution.
- *Regional Forwarding Rule:* `prime-lb` routing traffic to backend service `prime-service`.

## Automation
The entire deployment lifecycle is codified in `deploy.sh`.
