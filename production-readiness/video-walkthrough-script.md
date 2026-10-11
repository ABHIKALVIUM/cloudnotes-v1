# CloudNotes Production Readiness Video Walkthrough Script (3–6 Minutes)

**Presenter:** Abhishek Chaudhari (`abhishek.chaudhari@kalvium.community`)  
**Project:** CloudNotes Production Readiness Assessment (Lesson 5.11)  
**Target Duration:** 3 to 5 minutes  
**Format:** Screen Recording with Voiceover  

---

## Slide & Visual Flow Quick Reference

```
[00:00 - 00:45] Intro, GitHub PR, Source Commit & Scoped Release Boundary
       ↓
[00:45 - 02:30] Deep-Dive: 5 Dimensions (1 Key Evidence per Dimension + Missing Gaps)
       │  • Reliability: E02 (Failover drill log)
       │  • Observability: E06 (Alertmanager drill log)
       │  • Security: E09 / E10 (Negative access tests & Gitleaks audit)
       │  • Disaster Recovery: E13 vs MISSING-D2/D3 (The "Backup Trap")
       │  • Cost: E15 (Comparable sizing & 74% savings)
       ↓
[02:30 - 03:30] The Evidence Index & 20-Check Checklist
       ↓
[03:30 - 04:30] Scorecard (35/40), Gate Failure & The Defended NO-GO Verdict
       ↓
[04:30 - 05:00] Critical Gap Register, Retest Conditions & Conclusion
```

---

## Detailed Script & Teleprompter

### Segment 1: Introduction, PR, Reviewed Revision & Scope (00:00 – 00:45)
**Screen to Show:**
* GitHub Pull Request interface (or VS Code) showing branch `assessment/production-readiness`.
* Highlight reviewed base commit `f0638dd` and PR description.

**Spoken Words:**
> "Hello everyone. My name is Abhishek Chaudhari, and today I am presenting the Production Readiness Assessment for CloudNotes, concluding Modules 1 through 5.
>
> Here on screen is our assessment Pull Request on branch `assessment/production-readiness`, evaluating reviewed source commit `f0638dd`.
>
> Before rating any control, we strictly define our release scope: CloudNotes is being evaluated for an internal staging and simulated classroom demonstration using mock notes and dummy attachments under 50 requests per second.
>
> We also explicitly establish our operational boundary: testing on local Docker containers proves local recovery, but does not prove regional cloud failover or disaster recovery across availability zones."

---

### Segment 2: One Representative Evidence Item per Dimension (00:45 – 02:30)
**Screen to Show:** Open files in `production-readiness/evidence/` one by one.

#### 1. Reliability (Show `evidence/E02-local-failover-drill.log`):
> "Starting with **Reliability**, we examine Evidence **E02**, our LU 5.8 local failover drill. During active traffic, we injected an abrupt SIGKILL into our primary container. As seen in the log, our Nginx reverse proxy immediately re-routed in-flight requests to the secondary replica in 3.4 seconds with a 100% request success rate, while Docker auto-restarted the failed container in 7.2 seconds. This satisfies check R2."

#### 2. Observability (Show `evidence/E06-alertmanager-drill.log`):
> "For **Observability**, we look at Evidence **E06**, our Alertmanager drill. We simulated a 500 error spike to evaluate rule `CloudNotesHighErrorRate`. The alert transitioned to FIRING within 2 minutes 15 seconds, dispatched a webhook payload in 3.1 seconds, and delivered a page with our runbook link directly to the on-call engineer, who acknowledged the alert. This passes mandatory gate O2."

#### 3. Security (Show `evidence/E09-negative-access-results.log` & `evidence/E10-secret-leak-audit.txt`):
> "For **Security**, Evidence **E09** demonstrates 14 automated negative security tests. Path traversal attempts like `../../etc/passwd`, malicious `.php` executable uploads, and SQL injection payloads were 100% blocked with 4xx status codes. Companion evidence **E10** confirms a complete Gitleaks scan of our git history with zero credential leaks, passing gates S1 and S2."

#### 4. Disaster Recovery (Show `evidence/E13-backup-execution.log` & highlight MISSING-D2/D3):
> "Now let's examine **Disaster Recovery**. Evidence **E13** shows our automated backup script running on cron, producing a tarball of our SQLite database and uploads with a SHA-256 hash.
>
> **However, this is where we encounter the classic 'Backup Trap'.** As GitLab learned in their 2017 database incident, a running backup script is NOT proof of recovery. When inspecting our repository for Evidence **D2**—an isolated restore drill with database integrity verification—and **D3**—measured recovery time and data loss against our 30-minute RTO and 60-minute RPO—**NO RESTORE RECORD EXISTS.** We document this as an honest, unverified gap rather than staging a false demonstration. Both gates D2 and D3 are blocked."

#### 5. Cost (Show `evidence/E15-cost-sizing-comparison.md`):
> "Finally, in **Cost Optimization**, Evidence **E15** presents our LU 5.10 same-basis cost model in GCP `us-central1`. By right-sizing our over-provisioned `e2-standard-4` VM down to an autoscaled Managed Instance Group of `e2-micro` instances and offloading file attachments to Google Cloud Storage, we achieve a 74% cost reduction from $246.80 down to $64.20 per month."

---

### Segment 3: The Evidence Index & 20-Check Checklist (02:30 – 03:30)
**Screen to Show:**
* Scroll through `production-readiness/evidence-index.md`.
* Switch to `production-readiness/checklist.md` showing all 20 rows.

**Spoken Words:**
> "In our `evidence-index.md`, all 17 supporting artifacts and our explicit missing evidence entries are fully indexed with dates, environments, expected results, observed outcomes, and boundaries.
>
> Moving to `checklist.md`, we evaluated all 20 checks across the five dimensions without removing any hard checks. Reliability scored 8/8, Observability scored 8/8, Security scored 8/8, Cost scored 7/8, while Disaster Recovery scored only 4/8 due to unverified checks D2 and D3."

---

### Segment 4: Scorecard, Gate Audit & Defended NO-GO Verdict (03:30 – 04:30)
**Screen to Show:**
* Open `production-readiness/verdict.md`.
* Highlight the Score Summary Table, Mandatory Gates Table, and the "NO-GO" Verdict.

**Spoken Words:**
> "Here on `verdict.md` is our release decision.
>
> Our aggregate score is **35 out of 40 points**, or 87.5%, which clears the numerical 32-point threshold.
>
> **However, our release recommendation is an unequivocal NO-GO.**
>
> Why? Because **a score summarizes, but a gate decides.**
>
> Under our course release policy, release requires satisfying all dimensions above 6 points, passing all six mandatory gates, and having zero critical gaps.
>
> Disaster Recovery scored 4 out of 8, and mandatory release gates **D2** and **D3** failed to pass. Releasing CloudNotes to production without demonstrating that user data can actually be restored without corruption is a risk no responsible SRE can accept."

---

### Segment 5: Actionable Gaps, Retest Conditions & Conclusion (04:30 – 05:00)
**Screen to Show:**
* Scroll to the Critical Gap Register in `verdict.md` showing GAP-01 and GAP-02.

**Spoken Words:**
> "We turn this blocker into an actionable roadmap:
> * **GAP-01:** I am the assigned owner to execute an isolated restore drill in a clean staging environment by October 18th, verifying database integrity with `PRAGMA integrity_check` and application smoke tests.
> * **GAP-02:** Measure end-to-end recovery time and transaction loss to prove our 30-minute RTO and 60-minute RPO targets by October 18th.
>
> Once both retests pass, Gates D2 and D3 will be promoted to PASS, bringing our score to 39/40 and enabling a defensible release.
>
> Production readiness is a claim you can defend, not a checklist you can decorate. Thank you."

---

## Video Submission Checklist:
- [ ] PR branch `assessment/production-readiness` clearly visible.
- [ ] Reviewed commit `f0638dd` highlighted.
- [ ] 1 evidence artifact shown per dimension (E02, E06, E09, E13/Missing-D2, E15).
- [ ] Checklist and Evidence Index shown.
- [ ] Scorecard shown (35/40).
- [ ] Mandatory Gate failures (D2, D3) highlighted.
- [ ] Scoped NO-GO verdict defended.
- [ ] Actionable Gap Register shown with owners and retest dates.
- [ ] Video uploaded to Google Drive with permission set to: **Anyone with the link → Viewer**.
- [ ] Tested Google Drive link in an Incognito / Private browsing window.
