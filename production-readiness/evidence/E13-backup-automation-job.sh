#!/usr/bin/env bash
# ==============================================================================
# Evidence ID    : E13
# Script Name    : backup.sh (CloudNotes Automated Backup Script)
# Assessment Date: 2026-10-09
# Source Revision: f0638dd
# Supported Check: D1 (Disaster Recovery: Backup Coverage)
# ==============================================================================

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
DB_SRC="${DATABASE_PATH:-database/cloudnotes.db}"
UPLOADS_SRC="${UPLOAD_FOLDER:-uploads}"
ARCHIVE_NAME="cloudnotes-backup-${TIMESTAMP}.tar.gz"
TARGET_ARCHIVE="${BACKUP_DIR}/${ARCHIVE_NAME}"

mkdir -p "${BACKUP_DIR}"

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Starting automated backup job..."

# 1. Hot database backup using SQLite safe online backup API
TEMP_DB_BACKUP="${BACKUP_DIR}/cloudnotes-${TIMESTAMP}.db"
if [ -f "${DB_SRC}" ]; then
    sqlite3 "${DB_SRC}" ".backup '${TEMP_DB_BACKUP}'"
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] SQLite database hot backup created: ${TEMP_DB_BACKUP}"
else
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] WARNING: Source database file ${DB_SRC} not found!"
    exit 1
fi

# 2. Package database snapshot and uploads into compressed tar archive
tar -czf "${TARGET_ARCHIVE}" -C "${BACKUP_DIR}" "cloudnotes-${TIMESTAMP}.db" -C "$(dirname "${UPLOADS_SRC}")" "$(basename "${UPLOADS_SRC}")"
rm -f "${TEMP_DB_BACKUP}"

# 3. Calculate SHA-256 integrity checksum
sha256sum "${TARGET_ARCHIVE}" > "${TARGET_ARCHIVE}.sha256"

# 4. Retention policy: Prune local backup archives older than 30 days
find "${BACKUP_DIR}" -type f -name "cloudnotes-backup-*.tar.gz" -mtime +30 -delete

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Backup completed successfully."
echo "Archive: ${TARGET_ARCHIVE} ($(stat -c%s "${TARGET_ARCHIVE}" 2>/dev/null || stat -f%z "${TARGET_ARCHIVE}") bytes)"
echo "Checksum: $(cat "${TARGET_ARCHIVE}.sha256")"
