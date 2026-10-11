# Evidence E15: Comparable Cost Model & Resource Right-Sizing Analysis (LU 5.10)

- **Evidence ID:** E15
- **File / Resource Path:** `production-readiness/evidence/E15-cost-sizing-comparison.md`
- **Assessment Date:** 2026-10-09
- **Environment:** Google Cloud Pricing Calculator & LU 5.10 Cost Analysis Model
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** C1 (Cost: Comparable Analysis), C2 (Cost: Safe Sizing and Savings)

---

## 1. Cost Model Baseline & Methodology
To avoid misleading comparisons, both architectures are evaluated under identical standardized conditions:
* **Region:** Google Cloud Platform `us-central1` (Iowa).
* **Billing Period:** 730 runtime hours per month (100% active duty cycle).
* **Workload Baseline:** 20 requests/second steady-state, peak 50 req/s, 10,000 notes stored, 50 GB attachment storage, 150 GB egress network bandwidth.
* **Pricing Currency:** United States Dollars (USD).

---

## 2. Same-Basis Comparative Sizing & Cost Matrix

| Component Tier | Baseline Architecture (Unoptimized / Overprovisioned) | Right-Sized Architecture (Optimized Production) | Monthly Baseline Cost | Monthly Optimized Cost | Net Savings / Month (%) | Sizing & Optimization Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Compute Tier** | 1x `e2-standard-4` VM (4 vCPU, 16 GB RAM) - single unmanaged VM | 2x `e2-micro` VMs in Managed Instance Group (MIG) with autoscaling to 4 nodes | $97.10 | $16.80 | -$80.30 (-82.7%) | CloudNotes WSGI consumes <100m CPU and ~120MB RAM under 50 VUs (E04). `e2-standard-4` was >85% idle. 2x `e2-micro` across 2 zones provides true HA at a fraction of the cost. |
| **Database Tier** | Cloud SQL `db-custom-4-16` (4 vCPU, 16 GB RAM, 250 GB SSD provisioned) | Cloud SQL `db-custom-1-3840` (1 vCPU, 3.75 GB RAM, 20 GB SSD with storage auto-increase) | $118.40 | $38.20 | -$80.20 (-67.7%) | Current relational dataset is <10 MB. Provisioning 250 GB SSD and 4 vCPU wasted $80/mo in idle capacity. Right-sizing with automatic disk increase maintains headroom safely. |
| **Storage & Assets** | Compute Engine Persistent Disk standard 500 GB | Google Cloud Storage Standard (`gs://cloudnotes-uploads`) + Cloud CDN edge caching | $20.00 | $2.60 | -$17.40 (-87.0%) | Storing user uploads on VM disks creates multi-instance state fragmentation (ADR-003). GCS charges purely for actual bytes stored ($0.020/GB) with 11 9s durability. |
| **Networking & Ingress** | Unmanaged IP + raw egress bandwidth | Global External HTTP(S) Load Balancer + Cloud CDN (80% cache hit ratio on static assets) | $11.30 | $6.60 | -$4.70 (-41.6%) | Offloading static web assets (`static/css/`, `static/js/`) to CDN edge nodes reduces origin compute egress bandwidth and lowers WSGI thread saturation. |
| **Total Monthly Footprint** | | | **$246.80 / mo** | **$64.20 / mo** | **-$182.60 / mo (-74.0%)** | **Total annual projected savings: $2,191.20** |

---

## 3. Evaluation & Boundaries
* **Expected Result:** Rigorous, same-basis comparative analysis detailing resource sizing rationale and quantifiable cost reductions.
* **Observed Result:** Complete sizing table established showing 74% reduction ($246.80/mo down to $64.20/mo) while improving availability from single-node to multi-zone HA.
* **LIMITS:**
  * Sizing and cost calculations are projected estimates derived from Google Cloud Pricing Calculator and synthetic load profiles.
  * These estimates DO NOT represent actual historical GCP cloud invoices or measured billing meter readings.
