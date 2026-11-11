import json
import sqlite3
import tempfile
import threading
import unittest
from contextlib import closing
from http.server import ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from api.server import create_handler, initialize_database


class ApiServerTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.database_path = Path(self.temp_dir.name) / "test.sqlite3"
        initialize_database(self.database_path)
        self.server = ThreadingHTTPServer(
            ("127.0.0.1", 0), create_handler(self.database_path)
        )
        self.server.daemon_threads = False
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base_url = f"http://127.0.0.1:{self.server.server_port}"

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temp_dir.cleanup()

    def get_json(self, path):
        with urlopen(self.base_url + path) as response:
            return response.status, json.loads(response.read())

    def post_json(self, path, payload):
        request = Request(
            self.base_url + path,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urlopen(request) as response:
            return response.status, json.loads(response.read())

    def test_health_and_seeded_catalog(self):
        self.assertEqual(self.get_json("/health")[1]["status"], "ok")
        status, categories = self.get_json("/api/categories")
        self.assertEqual(status, 200)
        self.assertEqual(len(categories), 6)
        self.assertGreater(categories[0]["product_count"], 0)

        status, products = self.get_json("/api/products")
        self.assertEqual(status, 200)
        self.assertEqual(len(products), 87)
        self.assertIn("category_name", products[0])

    def test_search_barcode_and_missing_product(self):
        status, products = self.get_json("/api/products/search?query=613000100101")
        self.assertEqual(status, 200)
        self.assertEqual(products[0]["reference"], "AIO-156-PRO")

        status, product = self.get_json("/api/products/barcode/613000100101")
        self.assertEqual(status, 200)
        self.assertEqual(product["id"], 1)

        with self.assertRaises(HTTPError) as error:
            urlopen(self.base_url + "/api/products/barcode/not-found")
        self.assertEqual(error.exception.code, 404)

    def test_quote_is_saved_with_server_catalog_values(self):
        status, response = self.post_json(
            "/api/quotes",
            {
                "numero": "DEV-TEST-1",
                "customer_name": "Client NGNEX",
                "customer_phone": "+213555000000",
                "items": [
                    {
                        "product_id": 1,
                        "quantite": 2,
                        "prix_unitaire": 0.01,
                    }
                ],
            },
        )
        self.assertEqual(status, 201)
        self.assertEqual(response["numero"], "DEV-TEST-1")

        with closing(sqlite3.connect(self.database_path)) as connection:
            quote = connection.execute(
                "SELECT customer_name FROM Quotes WHERE numero = ?",
                ("DEV-TEST-1",),
            ).fetchone()
            item = connection.execute(
                """
                SELECT product_name, product_ref, quantite, prix_unitaire
                FROM QuoteItems WHERE quote_id = ?
                """,
                (response["id"],),
            ).fetchone()
        self.assertEqual(quote[0], "Client NGNEX")
        self.assertEqual(item, ("Terminal tactile NGNEX Pro 15,6 pouces", "AIO-156-PRO", 2, 85000.0))

    def test_quote_requires_customer_and_items(self):
        with self.assertRaises(HTTPError) as error:
            self.post_json(
                "/api/quotes",
                {"numero": "DEV-BAD", "items": []},
            )
        self.assertEqual(error.exception.code, 400)


if __name__ == "__main__":
    unittest.main()
