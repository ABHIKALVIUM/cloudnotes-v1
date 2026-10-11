import unittest
import json
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app
from utils.helpers import init_db

class CloudNotesDeploymentTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app
        self.client = self.app.test_client()

    def test_health_check(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data["status"], "healthy")
        self.assertEqual(data["service"], "CloudNotes")

    def test_home_page(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"CloudNotes", response.data)

    def test_notes_page(self):
        response = self.client.get("/notes")
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"Create a Note", response.data)

    def test_notes_api_crud_flow(self):
        # 1. Create Note
        post_response = self.client.post(
            "/api/notes",
            data={"title": "PyTest Note", "body": "Automated verification test body."},
        )
        self.assertEqual(post_response.status_code, 201)
        created_note = post_response.get_json()
        self.assertIn("id", created_note)
        note_id = created_note["id"]
        self.assertEqual(created_note["title"], "PyTest Note")

        # 2. Get Single Note
        get_response = self.client.get(f"/api/notes/{note_id}")
        self.assertEqual(get_response.status_code, 200)
        fetched_note = get_response.get_json()
        self.assertEqual(fetched_note["id"], note_id)
        self.assertEqual(fetched_note["body"], "Automated verification test body.")

        # 3. Get All Notes
        list_response = self.client.get("/api/notes")
        self.assertEqual(list_response.status_code, 200)
        notes_list = list_response.get_json()
        self.assertTrue(any(n["id"] == note_id for n in notes_list))

        # 4. Delete Note
        delete_response = self.client.delete(f"/api/notes/{note_id}")
        self.assertEqual(delete_response.status_code, 200)

        # 5. Verify 404 after deletion
        not_found_response = self.client.get(f"/api/notes/{note_id}")
        self.assertEqual(not_found_response.status_code, 404)

if __name__ == "__main__":
    unittest.main()
