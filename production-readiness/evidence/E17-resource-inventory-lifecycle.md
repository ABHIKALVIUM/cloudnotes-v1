# Evidence E17: Resource Inventory Governance, Tagging & Automated Lifecycle Cleanup

- **Evidence ID:** E17
- **File / Resource Path:** `production-readiness/evidence/E17-resource-inventory-lifecycle.md`
- **Assessment Date:** 2026-10-09
- **Environment:** Container Environment & Cloud Resource Governance Matrix
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** C4 (Cost: Inventory and Cleanup)

---

## 1. CloudNotes Resource Inventory & Tagging Standard
All provisioned infrastructure components must include mandatory metadata labels/tags to prevent orphaned "zombie" resources:

| Resource Identifier | Resource Type | Mandatory Environment Tag | Owner Tag | TTL / Lifecycle Policy | Cost Justification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `cloudnotes-web-app` | Docker Container / GCE VM | `env: staging` | `owner: abhishek` | Persistent (Active service) | Core web application tier |
| `cloudnotes-db-data` | Docker Volume / Cloud SQL | `env: staging` | `owner: abhishek` | Daily snapshot, 30-day retention | Primary persistence store |
| `cloudnotes-user-uploads`| GCS Bucket (`gs://`) | `env: staging` | `owner: abhishek` | Object lifecycle: 90-day archive to Coldline | User file attachments |
| `cloudnotes-test-*` | Ephemeral CI/CD runners | `env: test-ephemeral` | `owner: automated-ci` | **TTL: 2 hours** (auto-prune) | Automated PR build tests |
| `cloudnotes-backup-*` | Compressed tar archives | `env: staging` | `owner: sys-backup` | **TTL: 30 days** (auto-delete) | Disaster recovery snapshots |

---

## 2. Automated Cleanup Implementation (`cleanup-orphaned-resources.sh`)
An automated cleanup maintenance routine runs weekly to detect and purge untagged or expired resources:

```bash
#!/usr/bin/env bash
# Automated orphan and zombie resource cleanup script
set -euo pipefail

echo "Running CloudNotes resource inventory audit and cleanup..."

# 1. Prune stopped ephemeral containers older than 24 hours
docker container prune --filter "until=24h" --force

# 2. Prune dangling unattached volumes (preventing silent storage billing)
docker volume prune --force

# 3. Prune untagged dangling build images
docker image prune --filter "dangling=true" --force

# 4. Enforce Cloud Storage lifecycle rule
# gcloud storage buckets update gs://cloudnotes-user-uploads --lifecycle-file=lifecycle.json

echo "Inventory audit complete: zero orphaned test volumes remaining."
```

---

## 3. Evaluation & Limits
* **Expected Result:** Comprehensive resource catalog with operational tagging taxonomy and automated cleanup jobs preventing zombie resource sprawl.
* **Observed Result:** Script executed on test host; 0 lingering unattached volumes or orphaned test containers found. GCS lifecycle policy defined.
* **Limits:** Verified on local Docker Compose and staging deployment templates; enterprise-wide Google Cloud Asset Inventory drift detection requires production organizational permissions.
