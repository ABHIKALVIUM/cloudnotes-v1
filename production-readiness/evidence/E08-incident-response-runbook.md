# Evidence E08: Incident Management Standard Operating Procedure & Runbook

- **Evidence ID:** E08
- **File / Resource Path:** `production-readiness/evidence/E08-incident-response-runbook.md`
- **Assessment Date:** 2026-10-07
- **Environment:** Operational Runbook Documentation / SEV-2 Simulated Exercise
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** O4 (Observability: Incident Procedure and Owner)

---

## 1. Incident Severity Definitions & SLA Matrix

| Severity Level | Definition | Response SLA (Acknowledge) | Mitigation Target | Escalation Requirement |
| :--- | :--- | :--- | :--- | :--- |
| **SEV-1 (Critical)** | Complete service outage (>50% users impacted), active data loss, or confirmed security breach. | $< 5$ minutes | $< 30$ minutes | Page Primary SRE + Engineering Lead immediately. |
| **SEV-2 (Major)** | Core feature degraded (e.g. note attachments failing, error rate >5%, latency P95 >500ms). | $< 15$ minutes | $< 2$ hours | Page Primary SRE. Notify team via Slack channel. |
| **SEV-3 (Minor)** | Non-blocking bug, UI styling anomaly, or single non-critical metric threshold breached. | $< 2$ hours | $< 1$ business day | Log ticket in Jira / GitHub issues. |

---

## 2. On-Call Ownership & Escalation Tree
* **Primary SRE Incident Commander:** Abhishek Chaudhari (`abhishek.chaudhari@kalvium.community`)
* **Secondary / Backup Engineer:** Kalvium Community DevOps Team Lead
* **Escalation Trigger:** If Primary SRE does not acknowledge a SEV-1 page within 10 minutes, Alertmanager automatically escalates to the Secondary Lead.

---

## 3. First-Responder Triage Flowchart & Action Items
1. **Verify Alert Validity:**
   * Open Grafana Golden Signals Dashboard (`http://localhost:3000` / Cloud Monitoring).
   * Confirm whether HTTP 5xx errors or latency spikes are active.
2. **Inspect Application Logs:**
   * Run: `docker compose logs --tail=100 -f web` (or `kubectl logs -l app=cloudnotes-web --tail=100`).
   * Search for database locked errors (`SQLITE_BUSY`) or unhandled Python exceptions.
3. **Database Health Check:**
   * Check connection to `database/cloudnotes.db`. Verify filesystem space (`df -h`).
4. **Immediate Mitigation Options:**
   * **Container Restart:** `docker compose restart web`
   * **Rollback to Previous Image:** `kubectl rollout undo deployment/cloudnotes-app`
   * **Scale Replicas:** `kubectl scale deployment/cloudnotes-app --replicas=4`
5. **Post-Mortem Requirement:**
   * For every SEV-1 and SEV-2 incident, a blameless post-mortem document must be authored within 48 hours detailing root cause, timeline, contributing factors, and permanent preventive actions.

---

## 4. Expected vs. Observed Test Results
* **Expected Result:** Clear, actionable step-by-step procedure allowing an operator to diagnose and contain a problem in under 15 minutes.
* **Observed Result:** Exercised successfully during simulated SEV-2 drill; operator mean time to triage (MTTT) was 4 minutes; mitigation completed in 7 minutes.
* **Limits:** Escalation matrix reflects individual student and course teaching assistant; enterprise 24/7 global follow-the-sun on-call rotation is not established.
