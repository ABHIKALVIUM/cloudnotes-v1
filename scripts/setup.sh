#!/usr/bin/env bash
# ==============================================================================
# CloudNotes Linux Server Automated Setup Script
# Configures dependencies, PostgreSQL, systemd service, and firewall
# ==============================================================================
set -euo pipefail

echo "========================================================"
echo " CloudNotes Deployment Setup on Linux Server (Ubuntu) "
echo "========================================================"

# 1. Verify root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root (or with sudo)."
  exit 1
fi

# 2. Update packages and install prerequisites
echo "[+] Step 1: Installing system packages (Python, PostgreSQL, UFW, Git)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python3 python3-pip postgresql postgresql-contrib libpq-dev ufw curl

# 3. Create service user if it does not already exist
echo "[+] Step 2: Ensuring dedicated user 'cloudnotes' exists..."
if ! id -u cloudnotes >/dev/null 2>&1; then
  useradd -m -s /bin/bash cloudnotes
  echo "[+] Created service user: cloudnotes"
else
  echo "[+] Service user 'cloudnotes' already exists."
fi

APP_DIR="/home/cloudnotes/cloudnotes"
mkdir -p "$APP_DIR/uploads" "$APP_DIR/database"

# 4. Configure PostgreSQL
echo "[+] Step 3: Configuring PostgreSQL database and credentials..."
systemctl start postgresql
systemctl enable postgresql

sudo -u postgres psql -c "DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'cloudnotes') THEN
    CREATE ROLE cloudnotes WITH LOGIN PASSWORD 'cloudnotes_password';
  END IF;
END
\$\$;"

sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname = 'cloudnotes_db'" | grep -q 1 || \
sudo -u postgres psql -c "CREATE DATABASE cloudnotes_db OWNER cloudnotes;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE cloudnotes_db TO cloudnotes;"

# 5. Copy repository files to application directory if executing externally
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ "$REPO_ROOT" != "$APP_DIR" ]; then
  echo "[+] Copying application files to $APP_DIR..."
  cp -r "$REPO_ROOT"/* "$APP_DIR/" || true
fi

# 6. Setup .env file
if [ ! -f "$APP_DIR/.env" ]; then
  echo "[+] Generating production .env from .env.example..."
  cp "$APP_DIR/.env.example" "$APP_DIR/.env"
  sed -i "s/replace-with-a-secure-random-secret-key/$(openssl rand -hex 16)/" "$APP_DIR/.env"
fi

# 7. Install Python dependencies
echo "[+] Step 4: Installing Python dependencies via pip..."
pip3 install -r "$APP_DIR/requirements.txt"

# 8. Set correct file ownership
chown -R cloudnotes:cloudnotes "$APP_DIR"
chmod 600 "$APP_DIR/.env"

# 9. Run schema migrations
echo "[+] Step 5: Applying database migrations to PostgreSQL..."
sudo -u cloudnotes python3 "$APP_DIR/scripts/migrate.py"

# 10. Install and enable systemd service
echo "[+] Step 6: Installing systemd service unit..."
cp "$APP_DIR/cloudnotes.service" /etc/systemd/system/cloudnotes.service
systemctl daemon-reload
systemctl enable cloudnotes.service
systemctl restart cloudnotes.service

# 11. Configure OS firewall (UFW)
echo "[+] Step 7: Configuring firewall rules for port 5000/tcp..."
ufw allow 5000/tcp
ufw allow 22/tcp
ufw --force enable || true

echo "========================================================"
echo "[+] Deployment complete! CloudNotes service status:"
systemctl status cloudnotes.service --no-pager
echo "========================================================"
