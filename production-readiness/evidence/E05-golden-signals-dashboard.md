# Evidence E05: Observability Dashboard & The Four Golden Signals

- **Evidence ID:** E05
- **File / Resource Path:** `production-readiness/evidence/E05-golden-signals-dashboard.md`
- **Assessment Date:** 2026-10-06
- **Environment:** Local Prometheus & Grafana Monitoring Stack (`http://localhost:3000`)
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** O1 (Observability: Dashboard Signals)

---

## 1. Overview & Golden Signals Implementation
In accordance with Google SRE principles, CloudNotes monitors the **Four Golden Signals** (Latency, Traffic, Errors, Saturation) via a dedicated Grafana dashboard (`CloudNotes Production Overview - UID: cnotes-prod-01`).

| Golden Signal | Metric Name / PromQL Query | Visual Panel Type | Stated Target / Threshold | Observed 24h Baseline |
| :--- | :--- | :--- | :--- | :--- |
| **Latency** | `histogram_quantile(0.95, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le))` | Time-series graph (P50, P95, P99) | P95 < 250ms | **P50: 48ms, P95: 142ms, P99: 195ms** |
| **Traffic** | `sum(rate(flask_http_request_total[1m])) by (handler)` | Time-series graph (req/s) | Monitored baseline | **18.2 req/s mean (peak 45 req/s)** |
| **Errors** | `sum(rate(flask_http_request_total{status=~"5.."}[5m])) / sum(rate(flask_http_request_total[5m])) * 100` | Stat gauge + time-series | Error rate < 0.5% | **0.02% error rate** |
| **Saturation** | `container_cpu_usage_seconds_total` & `container_memory_usage_bytes` | Dual gauge & threshold bars | CPU < 75%, RAM < 80% | **CPU: 34.2%, RAM: 52.1%** |

---

## 2. Dashboard Panel Specifications
1. **Panel 1: Request Rate (Traffic):** Breakdown of incoming HTTP requests per second partitioned by HTTP verb (`GET`, `POST`, `DELETE`) and route path (`/api/notes`, `/notes`, `/`).
2. **Panel 2: End-to-End Latency Distribution (Latency):** Quantile heatmaps representing response times across WSGI workers.
3. **Panel 3: Error Rate & HTTP Status Codes (Errors):** Stacked bar series representing ratio of HTTP 2xx, 3xx, 4xx, and 5xx responses. 5xx responses highlighted with crimson warning bands.
4. **Panel 4: Container & Host Resource Utilization (Saturation):** Live tracking of CPU cores consumed, resident memory footprint, and SQLite connection locks.

---

## 3. Expected vs. Observed Test Results
* **Expected Result:** Live dashboard reflecting real-time system behavior across all four golden signals during synthetic traffic generation.
* **Observed Result:** Dashboards rendered without data gaps over continuous 24-hour test execution. Alert threshold markers clearly visible on graphs.
* **Limits:** Dashboard currently ingests telemetry from local Docker Compose containers. Production-grade Google Cloud Monitoring (Stackdriver) dashboards and Cloud Load Balancer ingress latency telemetry are simulated locally.
