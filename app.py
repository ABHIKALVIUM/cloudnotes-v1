import os
from flask import Flask, render_template, send_from_directory, jsonify
from dotenv import load_dotenv
from api.routes import api_bp
from utils.helpers import init_db, get_default_db_url

# Load environment variables from .env file if present
load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.getenv("UPLOAD_FOLDER", os.path.join(BASE_DIR, "uploads"))
DATABASE_URL = os.getenv("DATABASE_URL", get_default_db_url())
SECRET_KEY = os.getenv("SECRET_KEY", "cloudnotes-super-secret-key-change-in-production")
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", 5000))

app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
app.config["DATABASE_URL"] = DATABASE_URL
app.config["MAX_CONTENT_LENGTH"] = 5 * 1024 * 1024

app.register_blueprint(api_bp, url_prefix="/api")


# Ensure DB schema and uploads folder exist upon app boot
def setup_app_resources():
    try:
        init_db(app.config["DATABASE_URL"])
    except Exception as exc:
        app.logger.warning(f"Database initialization deferred: {exc}")
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)


with app.app_context():
    setup_app_resources()


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/notes")
def notes_page():
    return render_template("notes.html")


@app.route("/health")
def health_check():
    db_type = "PostgreSQL" if "postgres" in app.config["DATABASE_URL"] else "SQLite"
    return jsonify({
        "status": "healthy",
        "service": "CloudNotes",
        "database": db_type,
        "host": HOST,
        "port": PORT
    }), 200


@app.route("/uploads/<path:filename>")
def uploaded_file(filename):
    return send_from_directory(app.config["UPLOAD_FOLDER"], filename)


if __name__ == "__main__":
    app.run(debug=False, host=HOST, port=PORT)
