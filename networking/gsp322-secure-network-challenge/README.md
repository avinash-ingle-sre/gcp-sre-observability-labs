# GSP322: Build a Secure Google Cloud Network - Challenge Lab

## Architecture Overview
This directory contains the automation script to secure a VPC network by implementing the principle of least privilege using firewall rules and network tags.

- **Network:** `acme-vpc`
- **Compute Instances:**
  - `bastion`: Jump host for secure SSH access via Identity-Aware Proxy (IAP).
  - `juice-shop`: Web server running the application.
- **Firewall Rules Implemented:**
  - Deleted overly permissive rule (`open-access`).
  - Created `allow-ssh-iap` (TCP:22 from `35.235.240.0/20` to `bastion`).
  - Created `allow-ssh-internal` (TCP:22 from `acme-mgmt-subnet` CIDR to `juice-shop`).
  - Created `allow-http-juice-shop` (TCP:80 from `0.0.0.0/0` to `juice-shop`).
