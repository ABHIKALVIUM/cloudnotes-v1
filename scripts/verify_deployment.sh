#!/usr/bin/env bash
# ==============================================================================
# CloudNotes Deployment Verification & Diagnostic Suite
# Validates systemd self-healing, port binding, HTTP reachability,
# and database persistence.
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo " CloudNotes Automated Verification & Persistence Check   "
echo "=========================================================="

BASE_URL="http://127.0.0.1:5000"

# 1. Service Status
echo "[+] 1. Checking systemd service status..."
systemctl is-active --quiet cloudnotes && echo "    -> Service is ACTIVE" || (echo "[-] Service NOT active" && exit 1)

# 2. Port Binding
echo "[+] 2. Checking network socket binding (0.0.0.0:5000)..."
if netstat -tlpn 2>/dev/null | grep -q "0.0.0.0:5000"; then
  echo "    -> Port 5000 is correctly bound to 0.0.0.0"
else
  echo "[-] Warning: Could not detect 0.0.0.0:5000 via netstat"
fi

# 3. Health Endpoint
echo "[+] 3. Probing HTTP health endpoint..."
curl -fsS "$BASE_URL/health" | grep -q "healthy" && echo "    -> Health check returned OK" || (echo "[-] Health check failed" && exit 1)

# 4. Data Persistence Test - Part 1: Create Note
TEST_TITLE="Persistence-Verification-Note-$(date +%s)"
TEST_BODY="Verifying that data survives service restart and crashes in PostgreSQL."
echo "[+] 4. Writing test note to database: '$TEST_TITLE'..."

RESPONSE=$(curl -fsS -X POST "$BASE_URL/api/notes" \
  -F "title=$TEST_TITLE" \
  -F "body=$TEST_BODY")
echo "    -> Created Note Response: $RESPONSE"

NOTE_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | cut -d: -f2)
echo "    -> Registered Note ID: $NOTE_ID"

# 5. Service Self-Healing / Crash Survival Proof
echo "[+] 5. Testing Self-Healing: Killing CloudNotes gunicorn process..."
OLD_PID=$(systemctl show -p MainPID --value cloudnotes)
echo "    -> Original MainPID: $OLD_PID"

kill -9 "$OLD_PID" || true
echo "    -> Sent SIGKILL to PID $OLD_PID"
echo "    -> Waiting for systemd to automatically restart the service (Restart=always)..."
sleep 4

NEW_PID=$(systemctl show -p MainPID --value cloudnotes)
echo "    -> New MainPID after restart: $NEW_PID"

if [ "$OLD_PID" != "$NEW_PID" ] && [ "$NEW_PID" -gt 0 ]; then
  echo "    -> SUCCESS: systemd detected the crash and spawned new PID ($NEW_PID)!"
else
  echo "[-] FAILED: Service did not restart as expected."
  exit 1
fi

# 6. Data Persistence Test - Part 2: Verify Note Survives
echo "[+] 6. Querying note after service crash/restart..."
VERIFY_RESPONSE=$(curl -fsS "$BASE_URL/api/notes/$NOTE_ID")
echo "    -> Fetched Note: $VERIFY_RESPONSE"

if echo "$VERIFY_RESPONSE" | grep -q "$TEST_TITLE"; then
  echo "    -> SUCCESS: Note survived the crash and restart! Data is durable in PostgreSQL."
else
  echo "[-] FAILED: Note not found after service restart."
  exit 1
fi

echo "=========================================================="
echo " ALL DEPLOYMENT VERIFICATION CHECKS PASSED SUCCESSFULLY! "
echo "=========================================================="
