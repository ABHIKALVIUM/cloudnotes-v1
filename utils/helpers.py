import os
import sqlite3
from urllib.parse import urlparse
from dotenv import load_dotenv

load_dotenv()

ALLOWED_EXTENSIONS = {"txt", "md", "pdf", "png", "jpg", "jpeg", "gif"}

PG_SCHEMA = """
CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    filename VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
"""

SQLITE_SCHEMA = """
CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    filename TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
"""


def is_postgres(db_url):
    if not db_url:
        return False
    return db_url.startswith("postgresql://") or db_url.startswith("postgres://")


def get_default_db_url():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    default_sqlite = f"sqlite:///{os.path.join(base_dir, 'database', 'cloudnotes.db')}"
    return os.getenv("DATABASE_URL", default_sqlite)


def get_db_connection(db_url=None):
    if db_url is None:
        db_url = get_default_db_url()

    if is_postgres(db_url):
        import psycopg2
        from psycopg2.extras import RealDictCursor

        conn = psycopg2.connect(db_url, cursor_factory=RealDictCursor)
        return conn
    else:
        # SQLite
        path = db_url.replace("sqlite:///", "")
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        conn = sqlite3.connect(path)
        conn.row_factory = sqlite3.Row
        return conn


def init_db(db_url=None):
    if db_url is None:
        db_url = get_default_db_url()

    if is_postgres(db_url):
        conn = get_db_connection(db_url)
        with conn.cursor() as cursor:
            cursor.execute(PG_SCHEMA)
        conn.commit()
        conn.close()
    else:
        path = db_url.replace("sqlite:///", "")
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        conn = get_db_connection(db_url)
        with conn:
            conn.executescript(SQLITE_SCHEMA)
        conn.close()


def serialize_note(note):
    if note is None:
        return None
    data = dict(note)
    if "created_at" in data and data["created_at"] is not None:
        data["created_at"] = str(data["created_at"])
    return data


def fetch_all_notes(db_url=None):
    conn = get_db_connection(db_url)
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, title, body, filename, created_at FROM notes ORDER BY created_at DESC;")
        rows = cursor.fetchall()
        return [serialize_note(row) for row in rows]
    finally:
        conn.close()


def create_note_record(title, body, filename=None, db_url=None):
    if db_url is None:
        db_url = get_default_db_url()

    conn = get_db_connection(db_url)
    try:
        cursor = conn.cursor()
        if is_postgres(db_url):
            cursor.execute(
                "INSERT INTO notes (title, body, filename) VALUES (%s, %s, %s) RETURNING id, created_at;",
                (title, body, filename),
            )
            result = cursor.fetchone()
            conn.commit()
            return {
                "id": result["id"],
                "title": title,
                "body": body,
                "filename": filename,
                "created_at": str(result["created_at"]),
            }
        else:
            cursor.execute(
                "INSERT INTO notes (title, body, filename) VALUES (?, ?, ?);",
                (title, body, filename),
            )
            conn.commit()
            note_id = cursor.lastrowid
            return {
                "id": note_id,
                "title": title,
                "body": body,
                "filename": filename,
            }
    finally:
        conn.close()


def fetch_note_by_id(note_id, db_url=None):
    if db_url is None:
        db_url = get_default_db_url()

    conn = get_db_connection(db_url)
    try:
        cursor = conn.cursor()
        placeholder = "%s" if is_postgres(db_url) else "?"
        cursor.execute(
            f"SELECT id, title, body, filename, created_at FROM notes WHERE id = {placeholder};",
            (note_id,),
        )
        row = cursor.fetchone()
        return serialize_note(row)
    finally:
        conn.close()


def delete_note_by_id(note_id, db_url=None):
    if db_url is None:
        db_url = get_default_db_url()

    conn = get_db_connection(db_url)
    try:
        cursor = conn.cursor()
        placeholder = "%s" if is_postgres(db_url) else "?"
        cursor.execute(
            f"DELETE FROM notes WHERE id = {placeholder};",
            (note_id,),
        )
        conn.commit()
        return cursor.rowcount
    finally:
        conn.close()


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS
