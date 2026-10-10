# Traceable Evidence Index: CloudNotes Production Readiness Review

**Assessment Date:** 2026-10-10  
**Reviewed Base Revision:** `f0638dd`  
**Assessment Branch:** `assessment/production-readiness`  
**Review Lead / Assessor:** Abhishek Chaudhari (`abhishek.chaudhari@kalvium.community`)  
**Scope:** Staging / Simulated Classroom Demonstration Scope (Local Multi-Container & Cloud-Native Migration Target)

---

## 1. Traceable Evidence Register

This index establishes a complete, traceable mapping between operational claims and real underlying evidence artifacts. Every piece of evidence discloses its capture date, environment, source revision, expected outcome, observed outcome, operational limits, and supported readiness checks.

| Evidence ID | Repository-Relative Path | Artifact Description | Capture Date | Environment | Source Revision | Supported Checks | Status / Integrity |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **E01** | `production-readiness/evidence/E01-reliability-sli-slo.md` | Formal SLI/SLO mathematical formulas, Prometheus metric queries, and 30-day error budget policy. | 2026-10-04 | Local Docker / Prometheus | `f0638dd` | **R1** | Verified current |
| **E02** | `production-readiness/evidence/E02-local-failover-drill.log` | LU 5.8 local failover drill output: abrupt SIGKILL of primary container, Nginx upstream failover, and Docker restart. | 2026-10-04 | Docker Compose (2 web replicas + Nginx) | `f0638dd` | **R2** *(Gate)* | Verified current |
| **E03** | `production-readiness/evidence/E03-rollout-rollback-manifest.yaml` | Kubernetes rolling update manifest (`maxSurge: 1, maxUnavailable: 0`), liveness/readiness probes, and undo rollback record. | 2026-10-05 | Local Kubernetes (k3s) / Compose | `f0638dd` | **R3** | Verified current |
| **E04** | `production-readiness/evidence/E04-load-test-summary.json` | k6 load test results: 50 concurrent virtual users over 5 minutes; 2,548 requests, zero drops, P95 latency 138.4ms. | 2026-10-05 | Localhost reverse proxy | `f0638dd` | **R4** | Verified current |
| **E05** | `production-readiness/evidence/E05-golden-signals-dashboard.md` | Grafana dashboard specification & metric scrape history covering Google SRE's Four Golden Signals. | 2026-10-06 | Prometheus v2.48 / Grafana v10.2 | `f0638dd` | **O1** | Verified current |
| **E06** | `production-readiness/evidence/E06-alertmanager-drill.log` | Alertmanager drill log: simulated 500 error injection, alert transition to FIRING, webhook delivery in 3.1s, operator ACK. | 2026-10-06 | Prometheus Alertmanager stack | `f0638dd` | **O2** *(Gate)* | Verified current |
| **E07** | `production-readiness/evidence/E07-sanitized-app-logs.jsonl` | Structured JSON log stream showing trace IDs, performance telemetry, and regex redaction of passwords, tokens, and PII. | 2026-10-07 | Containerized Flask (structlog) | `f0638dd` | **O3** | Verified current |
| **E08** | `production-readiness/evidence/E08-incident-response-runbook.md` | Incident management standard operating procedure: severity levels (SEV 1-3), escalation matrix, on-call owner, MTTT metrics. | 2026-10-07 | Documentation / SEV-2 drill | `f0638dd` | **O4** | Verified current |
| **E09** | `production-readiness/evidence/E09-negative-access-results.log` | Automated negative security test suite: 14 assertions testing path traversal, malicious extensions, SQL injection, and CORS. | 2026-10-07 | Python unittest runner | `f0638dd` | **S1** *(Gate)* | Verified current |
| **E10** | `production-readiness/evidence/E10-secret-leak-audit.txt` | Gitleaks scan of entire repository git history (100% clean) and configuration audit confirming environment variable injection. | 2026-10-08 | Gitleaks v8.18 / Git history | `f0638dd` | **S2** *(Gate)* | Verified current |
| **E11** | `production-readiness/evidence/E11-dependency-security-audit.json` | pip-audit and Trivy container vulnerability scan report: 0 Critical/High CVEs; 1 Medium CVE triaged with upload size cap. | 2026-10-08 | CI/CD Security Scanner | `f0638dd` | **S3** | Verified current |
| **E12** | `production-readiness/evidence/E12-tls-network-isolation.md` | Nginx reverse proxy configuration enforcing TLS 1.3, HSTS, HTTP-to-HTTPS 301 redirection, and private Docker network binding. | 2026-10-08 | Local Nginx / Docker network | `f0638dd` | **S4** | Verified current |
| **E13** | `production-readiness/evidence/E13-backup-automation-job.sh` & `.log` | Automated backup job script and daily cron execution log creating tar.gz archive of database and uploads with SHA-256 hash. | 2026-10-09 | Scheduled cron runner | `f0638dd` | **D1** | Verified current (Backup only) |
| **MISSING-D2** | *None (Unverified Gap)* | **MISSING ARTIFACT:** No documented isolated restore drill, no database schema/row integrity verification test (`PRAGMA integrity_check`). | *None* | *Unverified* | *None* | **D2** *(Gate)* | **CRITICAL GAP (Blocks Gate D2)** |
| **MISSING-D3** | *None (Unverified Gap)* | **MISSING ARTIFACT:** No measured recovery duration (RTO) or measured data-loss delta (RPO) recorded during a timed recovery drill. | *None* | *Unverified* | *None* | **D3** *(Gate)* | **CRITICAL GAP (Blocks Gate D3)** |
| **E14** | `production-readiness/evidence/E14-disaster-recovery-runbook.md` | Documented disaster recovery runbook detailing step-by-step restore procedures, checksum validation, and traffic cutover. | 2026-10-09 | Documentation | `f0638dd` | **D4** | Verified current |
| **E15** | `production-readiness/evidence/E15-cost-sizing-comparison.md` | LU 5.10 same-basis cost model in GCP `us-central1` comparing unoptimized baseline ($246.80/mo) vs right-sized architecture ($64.20/mo). | 2026-10-09 | Google Cloud Pricing Calculator | `f0638dd` | **C1, C2** | Verified current (Estimate model) |
| **E16** | `production-readiness/evidence/E16-budget-alert-policy.json` | GCP Cloud Billing budget specification ($100 budget, 50%/80%/100% threshold rules, notification channels, financial owner). | 2026-10-09 | Cloud Billing Policy spec | `f0638dd` | **C3** | Verified current (Simulated webhooks) |
| **E17** | `production-readiness/evidence/E17-resource-inventory-lifecycle.md` | Infrastructure resource inventory catalog with mandatory environment/owner tags and automated orphan cleanup script. | 2026-10-09 | Docker / Cloud Governance | `f0638dd` | **C4** | Verified current |

---

## 2. Granular Evidence Analysis & Operational Boundaries

### E01 — Reliability Targets, SLI/SLO Specifications
* **Path:** `production-readiness/evidence/E01-reliability-sli-slo.md`
* **Expected Result:** Clear mathematical formulation of Availability ($\ge 99.5\%$) and Latency (P95 $< 250$ms) with PromQL expressions and a 30-day error budget policy.
* **Observed Result:** Documented and verified via `/metrics` endpoint. Baseline 72-hour synthetic test demonstrated 99.94% availability and 142ms P95 latency.
* **Operational Limits:** Metrics reflect local loopback and container network latency. Multi-region WAN hops, inter-zone database synchronization delays, and public internet packet drops are not represented in this local baseline.

### E02 — Local Failover & Crash Recovery Drill (LU 5.8)
* **Path:** `production-readiness/evidence/E02-local-failover-drill.log`
* **Expected Result:** When the primary web replica is abruptly killed (`SIGKILL`), the reverse proxy routes active in-flight requests to the secondary replica within 5 seconds without dropping user requests.
* **Observed Result:** Failover completed in 3.4 seconds. 34 out of 34 requests succeeded (100%). Single in-flight request retried transparently via `proxy_next_upstream`. Primary container auto-restarted via Docker restart policy in 7.2 seconds.
* **Operational Limits:** Proves local container crash recovery and reverse proxy retry behavior. **DOES NOT prove regional cloud failover or database crash recovery / restore.**

### E03 — Rollout & Rollback Manifest & Execution Record
* **Path:** `production-readiness/evidence/E03-rollout-rollback-manifest.yaml`
* **Expected Result:** Rolling update deploys new version with zero dropped connections (`maxUnavailable: 0`). Rollback command reverts bad releases upon readiness probe failure.
* **Observed Result:** Rolling update completed in 18s. Broken image release was blocked by readiness probe failure and reverted via `kubectl rollout undo` in 11.2s.
* **Operational Limits:** Verified in single-cluster staging environment; does not evaluate multi-region canary traffic splitting or Cloud Load Balancer backend drain delays.

### E04 — Capacity & Load Stress Test Summary
* **Path:** `production-readiness/evidence/E04-load-test-summary.json`
* **Expected Result:** 50 concurrent virtual users sustained for 5 minutes with P95 latency $< 250$ms, $< 0.1\%$ errors, and zero SQLite locking deadlocks.
* **Observed Result:** 2,548 requests completed with 0 errors (100% success rate). P95 latency was 138.4ms. Host CPU peak was 42.1%. Zero database locking deadlocks.
* **Operational Limits:** Workload originated from localhost. Does not test database connection pool saturation under distributed network latency or $>200$ concurrent write threads.

### E05 — Observability Dashboard & The Four Golden Signals
* **Path:** `production-readiness/evidence/E05-golden-signals-dashboard.md`
* **Expected Result:** Real-time visual panels tracking Latency, Traffic, Errors, and Saturation.
* **Observed Result:** Grafana dashboard ingested continuous Prometheus telemetry with drill-down capability across all four golden signals over 24-hour test window.
* **Operational Limits:** Telemetry reflects local container metrics. Cloud Load Balancer edge latency and managed Cloud SQL internal I/O wait metrics are simulated.

### E06 — Alertmanager Drill & Tested Response Record
* **Path:** `production-readiness/evidence/E06-alertmanager-drill.log`
* **Expected Result:** Simulated 500 errors trigger `CloudNotesHighErrorRate` rule; alert dispatches to webhook; on-call responder receives notification with runbook link.
* **Observed Result:** Alert transitioned to FIRING within 2m 15s. Webhook received payload in 3.1s. Primary on-call responder (Abhishek Chaudhari) acknowledged page. Auto-resolved when traffic normalized.
* **Operational Limits:** Notification tested via webhook receiver and email dispatch. Full enterprise PagerDuty rotation with secondary SMS/voice escalation was simulated.

### E07 — Sanitized Application Logs
* **Path:** `production-readiness/evidence/E07-sanitized-app-logs.jsonl`
* **Expected Result:** Machine-parseable JSON logs containing request IDs, timestamps, and error traces, with zero exposed passwords, auth tokens, or PII.
* **Observed Result:** Structured JSON logging verified. Automated regex filter masked sensitive payload fields to `[REDACTED]`. Zero plain credentials found in logs.
* **Operational Limits:** Local JSON file logging via Docker driver. Enterprise centralized logging aggregation (e.g. Google Cloud Logging / ELK) is simulated.

### E08 — Incident Response Standard Operating Procedure & Runbook
* **Path:** `production-readiness/evidence/E08-incident-response-runbook.md`
* **Expected Result:** Clear severity classification (SEV 1-3), escalation hierarchy, on-call owner, and actionable triage instructions enabling mitigation in $<15$ minutes.
* **Observed Result:** Documented procedure tested during simulated SEV-2 drill; operator mean time to triage (MTTT) was 4 minutes; mitigation completed in 7 minutes.
* **Operational Limits:** Escalation hierarchy reflects student author and course teaching assistant; enterprise 24/7 follow-the-sun rotation is not established.

### E09 — Negative Access Boundary Test Suite
* **Path:** `production-readiness/evidence/E09-negative-access-results.log`
* **Expected Result:** 100% of negative access tests (path traversal, malicious extensions, SQL injection, unauthorized verbs, oversized payloads) rejected with 4xx status codes.
* **Observed Result:** 14 out of 14 automated security assertions PASSED. No unauthorized file access or SQL injection bypass observed.
* **Operational Limits:** Validates application-level input validation and route isolation; does not test cloud-level WAF (Cloud Armor) rate-limiting against volumetric DDoS attacks.

### E10 — Secret Handling & Repository Leak Audit
* **Path:** `production-readiness/evidence/E10-secret-leak-audit.txt`
* **Expected Result:** Zero secrets, private keys, API credentials, or passwords committed across 100% of git history. Configuration handled via environment variables.
* **Observed Result:** Gitleaks scanned 5 commits across entire git tree: 0 leaks detected. Configuration parsed from environment variables with safe defaults.
* **Operational Limits:** Confirms repository cleanliness; does not validate automated 90-day secret rotation in live Google Secret Manager.

### E11 — Automated Vulnerability & Dependency CVE Audit
* **Path:** `production-readiness/evidence/E11-dependency-security-audit.json`
* **Expected Result:** Zero unmitigated Critical or High severity CVEs in Python dependencies and base container image.
* **Observed Result:** pip-audit and Trivy scanned packages: 0 Critical, 0 High vulnerabilities. 1 Medium Werkzeug CVE triaged and neutralized via `MAX_CONTENT_LENGTH` upload limit.
* **Operational Limits:** Snapshot as of 2026-10-08; continuous scanning must run in CI pipeline for ongoing vulnerability intelligence.

### E12 — Network Segmentation & Transport Layer Security (TLS)
* **Path:** `production-readiness/evidence/E12-tls-network-isolation.md`
* **Expected Result:** Flask backend isolated on internal network; Nginx reverse proxy terminates TLS 1.3 with HSTS; plain HTTP automatically redirected (301) to HTTPS.
* **Observed Result:** Confirmed via OpenSSL handshake (TLSv1.3 negotiated) and curl header check (HTTP 301 redirection active). Database access restricted to private network.
* **Operational Limits:** Local verification utilized self-signed test certificates. Cloud production requires Google-managed SSL certificates via Cloud Load Balancing.

### E13 — Automated Backup Job Script & Daily Execution Log
* **Path:** `production-readiness/evidence/E13-backup-automation-job.sh` & `.log`
* **Expected Result:** Automated backup script runs on daily cron schedule, packaging database snapshot and uploads folder into a compressed tar archive with SHA-256 integrity hash.
* **Observed Result:** Script executed at `2026-10-09T03:00:00Z`. Generated `cloudnotes-backup-20261009030000.tar.gz` (48,210 bytes) with valid SHA-256 hash.
* **Operational Limits & CRITICAL BOUNDARY WARNING:**
  * **Proves backup file creation only.**
  * **DOES NOT prove data restore capability (D2).**
  * **DOES NOT prove post-restore database schema integrity or application functionality (D2).**
  * **DOES NOT measure restore duration or data-loss window against RTO/RPO targets (D3).**

### MISSING-D2 — Isolated Restore & Data Integrity Verification (CRITICAL GAP)
* **Path:** *MISSING ARTIFACT (No file exists)*
* **Expected Result:** A dated, documented recovery drill log showing a clean database instance restored from backup archive E13, execution of database integrity checks (`PRAGMA integrity_check` returning `ok`), and automated application sanity tests proving notes are intact and retrievable.
* **Observed Result:** **NO RECORD EXISTS.** No isolated restore test has ever been performed. Recovery integrity is completely unproven.
* **Operational Impact:** **BLOCKS MANDATORY RELEASE GATE D2.** Releasing to production with unverified recovery integrity violates core operational safety principles (GitLab 2017 incident lesson).

### MISSING-D3 — Recovery Timing (RTO) and Data-Loss (RPO) Verification (CRITICAL GAP)
* **Path:** *MISSING ARTIFACT (No file exists)*
* **Expected Result:** Empirical measurement of actual recovery time against the declared RTO target ($< 30$ minutes) and empirical measurement of actual transaction data-loss window against the declared RPO target ($< 60$ minutes).
* **Observed Result:** **NO RECORD EXISTS.** Because an isolated restore drill was never executed, real recovery timing and data loss delta remain completely unmeasured.
* **Operational Impact:** **BLOCKS MANDATORY RELEASE GATE D3.** Recovery promises cannot be defended without empirical timing benchmarks.

### E14 — Disaster Recovery Standard Operating Procedure & Runbook
* **Path:** `production-readiness/evidence/E14-disaster-recovery-runbook.md`
* **Expected Result:** Documented step-by-step operator instructions detailing disaster declaration, backup retrieval, checksum verification, database restore, integrity assertions, and traffic cutover.
* **Observed Result:** Runbook document exists with clear operational instructions.
* **Operational Limits:** While the procedure is thoroughly documented, the recovery steps have never been executed in a live drill (directly resulting in Gaps MISSING-D2 and MISSING-D3).

### E15 — Comparable Cost Model & Resource Right-Sizing Analysis (LU 5.10)
* **Path:** `production-readiness/evidence/E15-cost-sizing-comparison.md`
* **Expected Result:** Rigorous same-basis comparison (GCP `us-central1`, 730 hrs/mo) between unoptimized baseline and right-sized production architecture, with explicit sizing justifications.
* **Observed Result:** Sizing model demonstrates a 74.0% cost reduction from $246.80/mo down to $64.20/mo ($2,191.20 annual savings). Right-sizing justified by low WSGI CPU/RAM profile under load (E04).
* **Operational Limits:** Calculations represent projected Google Cloud Pricing Calculator estimates based on synthetic workloads, not audited production cloud invoices.

### E16 — Budget Alert Policy & Financial Ownership
* **Path:** `production-readiness/evidence/E16-budget-alert-policy.json`
* **Expected Result:** Configured billing budget ($100/mo), tiered alert thresholds (50%, 80%, 100%), automated notifications, and designated financial owner.
* **Observed Result:** Policy specification committed with designated budget owner (Abhishek Chaudhari).
* **Operational Limits:** Evaluated locally. Automated Cloud Functions billing disabling and live GCP Cloud Billing API webhooks were not connected to live payment accounts. Scored as **PARTIAL (1 pt)**.

### E17 — Resource Inventory Governance, Tagging & Automated Lifecycle Cleanup
* **Path:** `production-readiness/evidence/E17-resource-inventory-lifecycle.md`
* **Expected Result:** Resource inventory catalog with mandatory metadata tags (`env`, `owner`, `ttl`) and automated cleanup scripts preventing zombie resource cost sprawl.
* **Observed Result:** Tagging standard defined. Cleanup script executed on test host; 0 orphaned test volumes or lingering containers found. GCS lifecycle policy documented.
* **Operational Limits:** Tested on local Docker Compose and template manifests; organization-level GCP Asset Inventory drift monitoring requires production organizational IAM permissions.
