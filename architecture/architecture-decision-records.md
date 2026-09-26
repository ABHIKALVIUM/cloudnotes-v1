# Architecture Decision Records (ADRs): CloudNotes Cloud Migration

**Project:** CloudNotes v1.0 to Cloud-Native GCP Migration  
**Status:** Approved / Proposed  
**Author:** Cloud Solutions Architect  
**Date:** September 2026  

---

## ADR-001: Migration from Local SQLite File to Managed Cloud SQL (PostgreSQL) with Multi-Zone High Availability

* **Status:** Accepted  
* **Date:** 2026-09-26  
* **Deciders:** Cloud Solutions Architecture Team  

### Context
CloudNotes v1.0 currently stores all note data in a local SQLite file (database/cloudnotes.db) on the host filesystem. While SQLite provides zero-configuration persistence on localhost, it relies on file-level locks that serialize write operations. Under concurrent web traffic or multi-instance horizontal scaling, concurrent writes fail with database is locked errors. Furthermore, a local file database on an ephemeral virtual machine provides no durability guarantees, automated backups, point-in-time recovery (PITR), or cross-zone disaster failover.

### Decision
Migrate the persistence layer from the local SQLite file to a fully managed **Google Cloud SQL for PostgreSQL** instance configured with **Multi-Zone High Availability (HA)** across us-central1-a (primary) and us-central1-b (synchronous standby). Cloud SQL will be configured exclusively with **Private Services Access (Private IP)** peered directly into the application VPC.

### Alternatives Considered
1. **Continue using SQLite on Compute Engine Persistent Disk or Cloud Filestore (NFS):** Rejected because multi-instance concurrent access to a shared SQLite file over network filesystems triggers file locking corruption, high latency, and severe write serialization bottlenecks.
2. **Self-hosted PostgreSQL on an unmanaged Compute Engine VM:** Rejected because it imposes significant operational overhead on the engineering team for manual OS patching, replication configuration, heartbeat monitoring, backup script maintenance, and complex manual failover orchestration.
3. **Google Cloud Spanner:** Evaluated as a globally distributed, horizontally scalable relational database. Rejected as over-engineered for the current CloudNotes relational schema and traffic profile, carrying unnecessary minimum cost overhead.

### Trade-offs
* **Benefits:** Provides automated synchronous multi-zone replication, automated zero-data-loss failover (<60s), automated daily snapshots, write-ahead log (WAL) archiving, point-in-time recovery, and seamless horizontal connection scaling. Fully decouples database persistence from the compute instance lifecycle.
* **Liabilities:** Incurs higher monthly managed service costs compared to an embedded file database. Introduces network latency (typically 1-2ms within the same GCP zone) compared to local memory/disk I/O, which is mitigated using connection pooling (PgBouncer) and persistent connection reuse.

---

## ADR-002: Stateless Compute Tier via Regional Managed Instance Groups (MIG) with Autoscaling & Cloud Load Balancing

* **Status:** Accepted  
* **Date:** 2026-09-26  
* **Deciders:** Cloud Solutions Architecture Team  

### Context
In CloudNotes v1.0, the Flask application runs as a single Python process listening on loopback 127.0.0.1:5000. The server mixes presentation, business logic, static asset delivery, and database queries within one operating system thread pool. In production, a single virtual machine represents a fatal Single Point of Failure (SPOF) and cannot scale beyond its local CPU and memory limits. Traffic spikes or unexpected process crashes lead to immediate application downtime.

### Decision
Architect the application tier as a completely **stateless compute cluster** running on **Google Compute Engine Managed Instance Groups (MIG)** distributed across multiple availability zones (us-central1-a and us-central1-b). Front the cluster with a **Global External HTTP(S) Load Balancer** that handles SSL/TLS termination, edge caching, and distributes traffic evenly across healthy VM instances. Implement horizontal autoscaling based on target CPU utilization (60%) and request rate, accompanied by automated health-check autohealing.

### Alternatives Considered
1. **Single Vertically Scaled Compute Engine VM (Scale-Up):** Rejected because vertical scaling requires machine downtime to resize vCPU/RAM, does not survive zonal hardware failures, and maintains an unacceptable Single Point of Failure.
2. **Google Kubernetes Engine (GKE):** Evaluated as a container orchestration platform. While powerful, deploying GKE for a single Flask web service introduces substantial operational complexity (Kubernetes cluster management, control plane costs, ingress controllers) that exceeds current organizational requirements.
3. **Google Cloud Run (Serverless Containers):** Considered as an alternative managed compute platform. While excellent for stateless containers, Compute Engine MIG was selected to align with the core VPC networking, custom systemd daemon management, and private infrastructure requirements of this migration phase.

### Trade-offs
* **Benefits:** Eliminates single-node bottlenecks through automated horizontal scaling (min 2, max 10 instances); provides high availability across multiple zones; automatically detects and replaces unhealthy instances via autohealing policies; ensures zero downtime rolling updates during application deployments.
* **Liabilities:** Requires strict enforcement of application statelessness - sessions and file writes cannot be stored on the local VM filesystem. Slightly higher provisioning latency during sudden traffic surges compared to instant serverless concurrency, which is mitigated by maintaining a minimum baseline of two active instances across zones.

---

## ADR-003: Offloading Uploaded Attachments and Static Assets to Google Cloud Storage (GCS) and Cloud CDN

* **Status:** Accepted  
* **Date:** 2026-09-26  
* **Deciders:** Cloud Solutions Architecture Team  

### Context
CloudNotes v1.0 writes user-uploaded attachments directly to the local disk path (./uploads/) and serves static files (./static/) through Flask's send_from_directory handler. In a multi-instance distributed cloud deployment, local disk storage causes severe state fragmentation: a file uploaded to VM-1 is unavailable when a subsequent request hits VM-2, resulting in HTTP 404 errors. Furthermore, streaming large binary attachments and static files through Python WSGI worker processes consumes CPU cycles, blocks request threads, and quickly exhausts local disk capacity.

### Decision
Decouple all unstructured binary storage from the compute layer by migrating user attachments to a dedicated **Google Cloud Storage (GCS) bucket** (gs://cloudnotes-user-uploads) and static web assets to an asset bucket (gs://cloudnotes-static-assets). Integrate **Cloud CDN** at the Load Balancer layer to cache static assets and public attachments at Google edge locations globally. Utilize **IAM Signed URLs** to allow client browsers to upload attachments directly to GCS, completely bypassing the Flask application servers.

### Alternatives Considered
1. **Shared Network Filesystem (Cloud Filestore / NFS) mounted on all VMs:** Rejected due to high minimum provisioned storage costs (1TB tier), NFS locking overhead, single-zone limitations of standard filestore instances, and operational management of POSIX mounts.
2. **Store Attachment Binaries as BLOBs inside PostgreSQL Database:** Rejected because storing large binary files inside the relational database inflates backup sizes, slows query performance, increases memory footprint, and drastically increases database I/O costs.
3. **Retain Local Disk Storage with Sticky Sessions (Session Affinity):** Rejected because sticky sessions do not solve instance termination, autoscaling scale-down data loss, or zonal failure scenarios.

### Trade-offs
* **Benefits:** Delivers 99.999999999% (11 9s) annual data durability, infinite horizontal storage capacity, built-in lifecycle management, and offloads 70-80% of network and I/O traffic from application VMs. Direct Signed URL uploads eliminate WSGI worker thread starvation during file transfers.
* **Liabilities:** Requires updating application code to use the Google Cloud Storage Python client library rather than POSIX open() / os.path operations, and requires managing IAM access permissions for bucket operations.

---

## ADR-004: Zero-Trust Network Perimeter Segregation using Private VPC Subnets, Cloud NAT, and Least-Privilege IAM

* **Status:** Accepted  
* **Date:** 2026-09-26  
* **Deciders:** Cloud Solutions Architecture Team  

### Context
In the local development environment, CloudNotes binds directly to 127.0.0.1:5000 with no network segmentation, authentication layer, or transport encryption. Directly deploying cloud VMs with public IP addresses exposes application runtimes and database ports to internet-wide automated port scans, brute-force attacks, and DDoS vulnerabilities. A single compromised application process would allow lateral movement to the database and internal infrastructure.

### Decision
Implement strict **Zero-Trust Network Perimeter Segregation** on Google Cloud Platform:
1. Construct a custom Virtual Private Cloud (VPC) network with distinct private subnets for application compute (10.0.1.0/24) and database services (10.0.2.0/24).
2. Assign **no public/external IP addresses** to Compute Engine VMs or Cloud SQL instances.
3. Establish the **Global External HTTP(S) Load Balancer** as the sole public-facing ingress point, backed by **Google Cloud Armor** for DDoS defense and WAF inspection.
4. Deploy **Google Cloud NAT** with Cloud Router to allow private VMs to perform secure outbound requests (e.g. security updates, pip package downloads, telemetry export) without allowing unsolicited inbound connections.
5. Enforce **Google Cloud IAM Least Privilege** via dedicated instance service accounts (cloudnotes-app-sa), coupled with **Google Secret Manager** for runtime injection of database credentials and cryptographic keys.

### Alternatives Considered
1. **Public IP Addresses with Host-Level Firewalls (UFW/iptables):** Rejected because exposing VMs directly to the public internet creates a massive attack surface and relies on error-prone per-host firewall configurations.
2. **Flat VPC Network with Mixed Public/Private Workloads:** Rejected because lack of subnet-level microsegmentation permits lateral compromise across application and database tiers in the event of an application exploit.
3. **Hardcoded Database Credentials in VM Environment Variables / Files:** Rejected due to high risk of secret leakage via version control, logging pipelines, or snapshot exposure.

### Trade-offs
* **Benefits:** Reduces public attack surface to a single hardened load balancer endpoint; guarantees that the database is completely unreachable from the internet; eliminates credential exposure through Secret Manager and IAM token rotation; complies with enterprise security standards.
* **Liabilities:** Adds minor operational complexity in network routing; requires Cloud NAT gateway egress bandwidth fees; requires configuring Identity-Aware Proxy (IAP) for administrative SSH access rather than open public SSH ports.
