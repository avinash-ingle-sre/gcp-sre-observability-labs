# GSP007: Set Up Network and HTTP Load Balancers

Setup of an External Passthrough Network Load Balancer on Google Cloud.

---

## Architectural Overview

1. **Backend Workloads:** Provisioned 3 Apache web servers (`www1`, `www2`, `www3`) using instance startup scripts.
2. **Target Pools:** Banded the instances together into a target pool (`www-pool`) governed by a legacy HTTP health check.
3. **Frontend:** Assigned a static regional IP and created a forwarding rule (`www-rule`) to route incoming port 80 traffic to the target pool.

---

## 🚠 🔎 **Verification & Validation Runbook** 🏅

Verify that your Load Balancer IP is active and successfully distributing traffic across the backend web servers.

```bash
# ✅ Step 1: Get the Load Balancer IP Address
IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region us-central1 --format="json" | jq -r .IPAddress)

# ✅ Step 2: Print the IP Address
echo "Load Balancer IP: $IPADDRESS"

# ✅ Step 3: Run a continuous curl loop to observe traffic distribution
while true; do curl -m1 $IPADDRESS; done
```

� **Expected Output:**
The response will alternate randomly between the healthy backend servers. *(Note: If it times out, wait 60 seconds for health checks to pass).*
```html
<h3>Web Server: www1</h3>
<h3>Web Server: www2</h3>
<h3>Web Server: www3</h3>
```

---

## Author
* **Avinash Ingle** - Site Reliability Engineer