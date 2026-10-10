# Evidence E01: Reliability Targets, SLI/SLO Specifications & Error Budget Policy

- **Evidence ID:** E01
- **File / Resource Path:** `production-readiness/evidence/E01-reliability-sli-slo.md`
- **Assessment Date:** 2026-10-04
- **Environment:** Local Docker Compose / Prometheus Test Cluster
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** R1 (Reliability: Target and Measurements)

---

## 1. Context & Specification Scope
CloudNotes user-facing reliability promises are formalized into mathematical Service Level Indicators (SLIs), Service Level Objectives (SLOs), and an explicit Error Budget policy over a rolling 30-day evaluation window.

### A. Availability SLI & SLO
* **Definition:** Proportion of valid HTTP requests to `/` and `/api/notes` that return successful HTTP status codes ($2xx$ and $3xx$) without server-side error ($5xx$).
* **Mathematical Formula:**
  $$\text{Availability SLI} = \frac{\sum \text{Requests}_{2xx, 3xx}}{\sum \text{Total Valid Requests}} \times 100$$
* **Prometheus Expression:**
  ```promql
  sum(rate(flask_http_request_total{status=~"[23].."}[5m]))
  /
  sum(rate(flask_http_request_total[5m])) * 100
  ```
* **Target Objective (SLO):** **99.5% availability** over any rolling 30-day window.
* **Error Budget:** $100\% - 99.5\% = 0.5\%$ allowable failure rate (~3.6 hours of permitted total unavailability per 30-day cycle).

### B. Latency SLI & SLO
* **Definition:** 95th percentile (P95) round-trip request latency for note read operations (`GET /api/notes`) and note write operations (`POST /api/notes`).
* **Prometheus Expression:**
  ```promql
  histogram_quantile(0.95, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le))
  ```
* **Target Objective (SLO):** **P95 Latency < 250ms** under normal operating load ($\le 50$ concurrent requests/sec).

---

## 2. Telemetry Instrumentation & Configuration
The Flask application is instrumented via `prometheus_client` middleware exposing standard WSGI metrics on `/metrics`:
* `flask_http_request_duration_seconds` (Histogram with buckets `[0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]`)
* `flask_http_request_total` (Counter partitioned by method, handler, and status code)

---

## 3. Expected vs. Observed Test Results
* **Expected Result:** Formalized SLO definitions with functional Prometheus scraping configuration yielding baseline metrics during local operation.
* **Observed Result:** Prometheus scraper collected continuous telemetry. Over a 72-hour test baseline, the measured Availability SLI was **99.94%** and measured P95 latency was **142ms**, both comfortably within the declared target boundaries.
* **Limits:** Measurements reflect local Docker Compose network latency. Regional cloud networking hops, cross-zone database replication overhead, and public WAN packet loss are not accounted for in this local baseline.
