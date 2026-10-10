# Evidence E14: Disaster Recovery Standard Operating Procedure & Runbook

- **Evidence ID:** E14
- **File / Resource Path:** `production-readiness/evidence/E14-disaster-recovery-runbook.md`
- **Assessment Date:** 2026-10-09
- **Environment:** Operational Runbook Documentation
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** D4 (Disaster Recovery: Recovery Procedure)

---

## 1. Disaster Declaration Criteria & Roles
* **Disaster Trigger:** Primary data volume loss, catastrophic SQLite database corruption, accidental drop of database tables, or primary host unrecoverable failure.
* **Incident Commander:** Primary SRE Lead (Abhishek Chaudhari).
* **Declared Objectives:**
  * **Target Recovery Time Objective (RTO):** $< 30$ minutes from declaration to healthy service restoration.
  * **Target Recovery Point Objective (RPO):** $< 60$ minutes maximum tolerated data loss.

---

## 2. Step-by-Step Operator Recovery Workflow
1. **Declare Disaster & Freeze Ingress:**
   * Divert client traffic to maintenance landing page at Nginx proxy / Cloud Load Balancer.
2. **Locate Latest Verified Backup Archive:**
   * Locate newest archive in `backups/cloudnotes-backup-<TIMESTAMP>.tar.gz` (or `gs://cloudnotes-backups/`).
3. **Verify Checksum:**
   * Run: `sha256sum -c cloudnotes-backup-<TIMESTAMP>.tar.gz.sha256`. Ensure exit code 0.
4. **Provision Clean Target Environment:**
   * Deploy clean container host / target instance.
5. **Extract & Restore Persistence Layer:**
   * Extract archive: `tar -xzvf cloudnotes-backup-<TIMESTAMP>.tar.gz -C /target/restore/`
   * Copy restored database: `cp /target/restore/cloudnotes-*.db /data/cloudnotes.db`
   * Copy restored uploads: `cp -r /target/restore/uploads/* /uploads/`
6. **Data Integrity Verification Assertions:**
   * Run SQLite integrity check: `sqlite3 /data/cloudnotes.db "PRAGMA integrity_check;"` (Must return `ok`).
   * Validate note count: `sqlite3 /data/cloudnotes.db "SELECT count(*) FROM notes;"`.
7. **Application Sanity Verification:**
   * Boot Flask container in isolated staging mode.
   * Query API: `curl -s http://localhost:5000/api/notes | jq .`
   * Verify HTTP 200 response and correct note payload.
8. **Shift Traffic Back to Production:**
   * Remove maintenance page routing; restore live ingress traffic.

---

## 3. Evaluation & Critical Gap Identification
* **Expected Result:** Clear, comprehensive procedural documentation for operators.
* **Observed Result:** Runbook document exists and outlines full recovery procedure.
* **CRITICAL OPERATIONAL GAP (D2 & D3 Blocker):**
  * While this runbook is fully documented on paper, **Steps 4 through 7 have NEVER been exercised in a live, dated restore drill!**
  * Recovery duration (RTO) and actual transaction delta (RPO) remain purely theoretical.
  * Until an isolated restore drill is executed and documented, actual recovery capability remains UNVERIFIED.
