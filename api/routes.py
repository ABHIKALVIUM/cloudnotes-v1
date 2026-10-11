import os
from flask import Blueprint, jsonify, request, current_app
from werkzeug.utils import secure_filename
from utils.helpers import (
    fetch_all_notes,
    create_note_record,
    fetch_note_by_id,
    delete_note_by_id,
    allowed_file,
)

api_bp = Blueprint("api", __name__)


@api_bp.route("/notes", methods=["GET"])
def get_notes():
    db_url = current_app.config.get("DATABASE_URL")
    notes = fetch_all_notes(db_url)
    return jsonify(notes), 200


@api_bp.route("/notes", methods=["POST"])
def create_note():
    title = request.form.get("title", "Untitled Note")
    body = request.form.get("body", "")
    filename = None

    uploaded_file = request.files.get("attachment")
    if uploaded_file and allowed_file(uploaded_file.filename):
        filename = secure_filename(uploaded_file.filename)
        upload_folder = current_app.config.get("UPLOAD_FOLDER")
        os.makedirs(upload_folder, exist_ok=True)
        destination = os.path.join(upload_folder, filename)
        uploaded_file.save(destination)

    db_url = current_app.config.get("DATABASE_URL")
    note = create_note_record(title, body, filename, db_url)
    return jsonify(note), 201


@api_bp.route("/notes/<int:note_id>", methods=["GET"])
def get_note(note_id):
    db_url = current_app.config.get("DATABASE_URL")
    note = fetch_note_by_id(note_id, db_url)
    if note is None:
        return jsonify({"error": "Note not found"}), 404
    return jsonify(note), 200


@api_bp.route("/notes/<int:note_id>", methods=["DELETE"])
def delete_note(note_id):
    db_url = current_app.config.get("DATABASE_URL")
    deleted_count = delete_note_by_id(note_id, db_url)
    if deleted_count == 0:
        return jsonify({"error": "Note not found"}), 404
    return jsonify({"message": "Note deleted"}), 200
