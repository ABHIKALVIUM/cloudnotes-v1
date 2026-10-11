# CloudNotes Linux Server Deployment Guide

This document details the complete deployment of the **CloudNotes** web application to an always-on Linux server environment (Ubuntu 22.04 LTS on WSL2 with native `systemd` enabled).

---

## 1. System Overview

* **Operating System:** Ubuntu 22.04.5 LTS (Linux kernel 5.15.167.4-microsoft-standard-WSL2)
* **Init & Service Supervisor:** `systemd` (PID 1)
* **Application Framework:** Flask 3.1.3 (Python 3.10)
* **Production WSGI Server:** Gunicorn 26.2.0 (running 2 worker processes, 2 threads each)
* **Database Engine:** PostgreSQL 14 (replaces legacy SQLite)
* **Firewall / Ingress Security:** UFW (`ufw allow 5000/tcp`)
* **Service User Context:** `cloudnotes` (unprivileged POSIX user, UID 1000)

---

## 2. The Complete Request Access Path

Understanding the network path from the user's browser down to the WSGI application layer is crucial for operational observability and troubleshooting:

```
[Web Browser]
      │
      ▼ (HTTP Request: http://localhost:5000 or http://<VM-IP>:5000)
[Host / VM Virtual Network Adapter]
      │
      ▼ (Virtual Ethernet Bridge / Routing)
[OS Firewall (UFW) - Port 5000/tcp]
      │
      ▼ (Permits ingress traffic matching rule '5000/tcp ALLOW IN')
[Linux Server Network Stack (0.0.0.0:5000)]
      │
      ▼ (Socket listening on INADDR_ANY across all interfaces)
[Gunicorn WSGI Master & Worker Processes]
      │
      ▼ (WSGI interface dispatch)
[Flask Application Runtime & API Blueprint]
      │
      ▼ (Database queries over TCP socket localhost:5432)
[PostgreSQL Database Engine (cloudnotes_db)]
```

### Trace of Request Hops:
1. **Your Browser:** The user enters `http://localhost:5000` (or the server IP) in Google Chrome or Edge.
2. **Host / VM Network:** Traffic travels across the host networking layer to the virtual network adapter of the Linux environment.
3. **OS Firewall / Open Port:** The Linux kernel Netfilter firewall (managed by `ufw`) evaluates incoming packets against defined rules (`ufw allow 5000/tcp`). Because the port is open, packets pass through without being dropped.
4. **Linux Server Socket Binding:** Gunicorn is bound to `0.0.0.0:5000` (INADDR_ANY), meaning it accepts incoming connections from any network interface, rather than restricting to loopback `127.0.0.1`.
5. **Flask Application:** Gunicorn passes the HTTP environment to Flask, which processes requests, queries PostgreSQL, and returns responses.

---

## 3. Step-by-Step Deployment & Setup Commands

### Step 3.1: Install Operating System Packages
```bash
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip postgresql postgresql-contrib libpq-dev ufw curl net-tools
```

### Step 3.2: Create Dedicated Service User
Never run production applications as `root`. We create an unprivileged user:
```bash
sudo useradd -m -s /bin/bash cloudnotes
```

### Step 3.3: Configure PostgreSQL Database
```bash
# Ensure PostgreSQL service is active
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database user and database
sudo -u postgres psql -c "CREATE USER cloudnotes WITH PASSWORD 'cloudnotes_password';"
sudo -u postgres psql -c "CREATE DATABASE cloudnotes_db OWNER cloudnotes;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE cloudnotes_db TO cloudnotes;"
```

### Step 3.4: Deploy Application Files & Dependencies
```bash
APP_DIR="/home/cloudnotes/cloudnotes"
sudo mkdir -p "$APP_DIR"

# Copy repo contents into app directory
sudo cp -r . "$APP_DIR/"
sudo chown -R cloudnotes:cloudnotes "$APP_DIR"

# Install Python requirements
sudo pip3 install -r "$APP_DIR/requirements.txt"
```

### Step 3.5: Configure Environment Variables
Copy `.env.example` to `.env` and set production secrets:
```bash
sudo cp "$APP_DIR/.env.example" "$APP_DIR/.env"
# Restrict file permissions to cloudnotes user only
sudo chmod 600 "$APP_DIR/.env"
sudo chown cloudnotes:cloudnotes "$APP_DIR/.env"
```

### Step 3.6: Run Database Schema Migrations
```bash
sudo -u cloudnotes python3 "$APP_DIR/scripts/migrate.py"
```

### Step 3.7: Install and Enable `systemd` Service
Deploy the unit file to `/etc/systemd/system/cloudnotes.service`:
```bash
sudo cp "$APP_DIR/cloudnotes.service" /etc/systemd/system/cloudnotes.service
sudo systemctl daemon-reload
sudo systemctl enable cloudnotes.service
sudo systemctl start cloudnotes.service
```

Verify service status:
```bash
sudo systemctl status cloudnotes.service
```

### Step 3.8: Open Firewall Port
```bash
sudo ufw allow 5000/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable
sudo ufw status verbose
```

---

## 4. Verification & Testing

### 4.1 Checking Service Health
```bash
curl -i http://localhost:5000/health
```
Expected output:
```json
HTTP/1.1 200 OK
{"database":"PostgreSQL","host":"0.0.0.0","port":5000,"service":"CloudNotes","status":"healthy"}
```

### 4.2 Proving Boot Auto-Start and Crash Self-Healing
1. **Crash Recovery Test:**
   ```bash
   MAIN_PID=$(systemctl show -p MainPID --value cloudnotes)
   echo "Killing PID $MAIN_PID..."
   sudo kill -9 $MAIN_PID
   sleep 3
   systemctl status cloudnotes
   ```
   *Result:* Because `Restart=always` is configured, systemd detects the process termination and immediately launches a new instance with a fresh PID.

2. **Reboot Recovery Test:**
   ```bash
   sudo reboot # or restart the WSL/VM instance
   ```
   *Result:* Upon boot, systemd triggers `multi-user.target`, which automatically launches `cloudnotes.service`.

### 4.3 Proving Data Persistence in PostgreSQL
1. Create a note via API:
   ```bash
   curl -X POST http://localhost:5000/api/notes \
     -F "title=Persistent Note" \
     -F "body=This note must survive restart"
   ```
2. Restart the service:
   ```bash
   sudo systemctl restart cloudnotes
   ```
3. Query the notes list:
   ```bash
   curl http://localhost:5000/api/notes
   ```
   *Result:* The note remains fully intact in PostgreSQL.
