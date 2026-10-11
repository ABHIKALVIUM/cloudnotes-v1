# Evidence E12: Network Segmentation, Transport Encryption (TLS) & Data Exposure Controls

- **Evidence ID:** E12
- **File / Resource Path:** `production-readiness/evidence/E12-tls-network-isolation.md`
- **Assessment Date:** 2026-10-08
- **Environment:** Local Reverse Proxy (Nginx) & Docker Network Isolation / Cloud VPC Topology
- **Source Revision / Commit:** `f0638dd`
- **Supported Check(s):** S4 (Security: Network, Transport, and Data Exposure)

---

## 1. Network Boundary Segmentation & Ingress Controls
CloudNotes enforces strict multi-tier network segregation:
1. **Isolated Internal Network:** The Python/Flask WSGI application process binds exclusively to loopback (`127.0.0.1:5000`) or within an internal Docker bridge network (`172.28.0.0/16`). No application ports or database files are exposed directly to public network interfaces.
2. **Hardened Ingress Proxy:** All inbound traffic must traverse the front-end reverse proxy (Nginx / Google Cloud Load Balancer) on port 443 (HTTPS).
3. **Database Network Isolation:** In the cloud-native architecture (ADR-001 & ADR-004), Google Cloud SQL communicates strictly via Private Services Access (Private IP `10.0.2.0/24`) peered directly into the application VPC, completely disabled from the public internet.

---

## 2. Transport Layer Security (TLS 1.3) Enforcement
Nginx ingress configuration enforces modern cryptography:
* **Protocols:** `TLSv1.2 TLSv1.3` (SSLv2, SSLv3, TLS 1.0, and TLS 1.1 explicitly disabled).
* **Ciphers:** `ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384`.
* **HSTS:** `Strict-Transport-Security "max-age=31536000; includeSubDomains" always;`.
* **HTTP to HTTPS Redirection:** Port 80 listener issues automatic `301 Moved Permanently` redirecting to `https://$host$request_uri`.

---

## 3. Test Verification & Results
* **Verification 1 (HTTP Redirect):**
  ```bash
  $ curl -I http://localhost:8080/
  HTTP/1.1 301 Moved Permanently
  Location: https://localhost:8443/
  ```
* **Verification 2 (TLS Handshake):**
  ```bash
  $ openssl s_client -connect localhost:8443 -tls1_3
  New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
  Verify return code: 0 (ok)
  ```
* **Expected Result:** Plain HTTP requests rejected or redirected; unencrypted plaintext transmission blocked; database inaccessible externally.
* **Observed Result:** Full transport encryption confirmed; zero plaintext database leakage; secure headers active.
* **Limits:** Local testing utilized self-signed TLS certificates; public cloud production requires Google-managed certificates with automated 90-day renewal.
