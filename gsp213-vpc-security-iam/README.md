#GSP213: Control Access to Google Cloud VPC Networks

Enterprise NGYNX web server hardening via Tagged VPC Firewall Rules and IAM Least-Privilege Network/Security Admin Separation.

---

## Architectural Overview

1. *Tagged Ingress Firewall Hardening:*
   * Provisioned two identical NGINH servers (`blue` and `green`) in the default VTC.
   * Applied `web-server` network tag exclusively to `blue`.
   * Firewall rule `allow-http-web-server` bound only to the tag, preventing unauthorized external HTTP access to `green` while allowing internal VPC traffic.

2. *IAM Separation of Duties (SoD): ** 
   * *Compute Network Admin*: Permissions to manage VTC subnets, routes, and *view* firewalls (unable to mutate/delete).
   * *Compute Security Admin*: Exclusive permissions to create, apply, and delete firewall rules and SSL certificates.

---

## Verification Runbook

```bash
# Create Tagged Ingress Rule
gcloud compute firewall-rules create allow-http-web-server \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80,icmp \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# Verify IOM Boundaries
 gcloud auth activate-service-account --key-file credentials.json
--try deleting firewall (must fail with Network Admin, ducceed with Security Admin)
```J
---

## Author
* **Avinash Ingle** - Site Reliability Engineer
