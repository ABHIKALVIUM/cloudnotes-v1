#!/usr/bin/env python3
"""
CloudNotes Database Migration Script
Applies the schema definitions to PostgreSQL (or SQLite fallback)
and verifies table creation.
"""
import os
import sys
from dotenv import load_dotenv

# Add parent directory to path so imports work cleanly
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.helpers import init_db, get_default_db_url, get_db_connection, is_postgres

def run_migrations():
    load_dotenv()
    db_url = os.getenv("DATABASE_URL", get_default_db_url())
    db_type = "PostgreSQL" if is_postgres(db_url) else "SQLite"

    print(f"[*] Starting CloudNotes database migration...")
    print(f"[*] Target database engine: {db_type}")
    print(f"[*] Connection URL: {db_url.split('@')[-1] if '@' in db_url else db_url}")

    try:
        init_db(db_url)
        print(f"[+] Schema applied successfully.")

        # Verification step
        conn = get_db_connection(db_url)
        cursor = conn.cursor()
        if is_postgres(db_url):
            cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
            tables = [row["table_name"] for row in cursor.fetchall()]
        else:
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
            tables = [row["name"] for row in cursor.fetchall()]
        conn.close()

        print(f"[+] Verified active tables: {tables}")
        if "notes" in tables:
            print("[+] Migration check PASSED: 'notes' table is ready for durable storage.")
            return True
        else:
            print("[-] Error: 'notes' table was not found after migration.")
            return False
    except Exception as exc:
        print(f"[-] Migration failed with error: {exc}")
        return False

if __name__ == "__main__":
    success = run_migrations()
    sys.exit(0 if success else 1)
