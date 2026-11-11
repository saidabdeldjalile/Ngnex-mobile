#!/usr/bin/env python3
"""Local development API for NGNEX Mobile."""

from __future__ import annotations

import json
import os
import sqlite3
from contextlib import closing
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlsplit


ROOT = Path(__file__).resolve().parent.parent
SCHEMA_FILE = ROOT / "Database" / "database.sql"
DEFAULT_DB_FILE = Path(__file__).resolve().parent / "data" / "ngnex_api.sqlite3"
MAX_BODY_SIZE = 1024 * 1024


def initialize_database(database_path: Path) -> None:
    database_path.parent.mkdir(parents=True, exist_ok=True)
    with closing(sqlite3.connect(database_path)) as connection:
        connection.execute("PRAGMA foreign_keys = ON")
        connection.executescript(SCHEMA_FILE.read_text(encoding="utf-8-sig"))
        connection.commit()


def product_json(row: sqlite3.Row) -> dict:
    return {
        "id": row["id"],
        "category_id": row["category_id"],
        "category_name": row["category_name"],
        "nom": row["nom"],
        "reference": row["reference"],
        "barcode": row["barcode"] or "",
        "description": row["description"] or "",
        "prix": row["prix"],
        "stock": row["stock"],
        "image_url": row["image_url"] or "",
        "caracteristiques": row["caracteristiques"] or "",
        "updated_at": row["updated_at"] or "",
    }


def create_handler(database_path: Path) -> type[BaseHTTPRequestHandler]:
    class ApiHandler(BaseHTTPRequestHandler):
        server_version = "NGNEX-Local-API/1.0"

        def log_message(self, format_string: str, *args: object) -> None:
            print(f"{self.address_string()} - {format_string % args}")

        def send_json(self, status: int, payload: object, head_only: bool = False) -> None:
            body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            if not head_only:
                self.wfile.write(body)

        def do_GET(self) -> None:
            self.handle_get()

        def do_HEAD(self) -> None:
            self.handle_get(head_only=True)

        def handle_get(self, head_only: bool = False) -> None:
            parsed = urlsplit(self.path)
            path = unquote(parsed.path)
            query = parse_qs(parsed.query)

            if path == "/health":
                self.send_json(200, {"status": "ok", "service": "ngnex-api"}, head_only)
                return

            if not path.startswith("/api/"):
                self.send_json(404, {"error": "Route introuvable."}, head_only)
                return

            try:
                with closing(sqlite3.connect(database_path)) as connection:
                    connection.row_factory = sqlite3.Row
                    connection.execute("PRAGMA foreign_keys = ON")

                    if path == "/api/categories":
                        rows = connection.execute(
                            """
                            SELECT c.id, c.nom, c.description, c.image_url,
                                   COUNT(p.id) AS product_count
                            FROM Categorie c
                            LEFT JOIN Product p ON p.category_id = c.id
                            GROUP BY c.id
                            ORDER BY c.nom
                            """
                        ).fetchall()
                        self.send_json(200, [dict(row) for row in rows], head_only)
                        return

                    if path in ("/api/products", "/api/products/search"):
                        filters: list[str] = []
                        values: list[object] = []
                        if path.endswith("/search"):
                            term = query.get("query", [""])[0].strip()
                            if not term:
                                self.send_json(
                                    400, {"error": "Le paramètre query est obligatoire."}, head_only
                                )
                                return
                            filters.append(
                                "(p.nom LIKE ? OR p.reference LIKE ? OR p.barcode LIKE ?)"
                            )
                            pattern = f"%{term}%"
                            values.extend((pattern, pattern, pattern))

                        category_id = query.get("category_id", [""])[0].strip()
                        if category_id:
                            try:
                                category_value = int(category_id)
                            except ValueError:
                                self.send_json(
                                    400, {"error": "category_id doit être un entier."}, head_only
                                )
                                return
                            filters.append("p.category_id = ?")
                            values.append(category_value)

                        where_clause = (
                            " WHERE " + " AND ".join(filters) if filters else ""
                        )
                        rows = connection.execute(
                            """
                            SELECT p.*, c.nom AS category_name
                            FROM Product p
                            JOIN Categorie c ON c.id = p.category_id
                            """
                            + where_clause
                            + " ORDER BY p.id",
                            values,
                        ).fetchall()
                        self.send_json(200, [product_json(row) for row in rows], head_only)
                        return

                    if path.startswith("/api/products/barcode/"):
                        barcode = path.removeprefix("/api/products/barcode/").strip()
                        row = connection.execute(
                            """
                            SELECT p.*, c.nom AS category_name
                            FROM Product p
                            JOIN Categorie c ON c.id = p.category_id
                            WHERE p.barcode = ?
                            """,
                            (barcode,),
                        ).fetchone()
                        if row is None:
                            self.send_json(404, {"error": "Produit introuvable."}, head_only)
                        else:
                            self.send_json(200, product_json(row), head_only)
                        return

                    product_prefix = "/api/products/"
                    if path.startswith(product_prefix):
                        product_id_text = path[len(product_prefix):]
                        try:
                            product_id = int(product_id_text)
                        except ValueError:
                            self.send_json(404, {"error": "Produit introuvable."}, head_only)
                            return
                        row = connection.execute(
                            """
                            SELECT p.*, c.nom AS category_name
                            FROM Product p
                            JOIN Categorie c ON c.id = p.category_id
                            WHERE p.id = ?
                            """,
                            (product_id,),
                        ).fetchone()
                        if row is None:
                            self.send_json(404, {"error": "Produit introuvable."}, head_only)
                        else:
                            self.send_json(200, product_json(row), head_only)
                        return

                self.send_json(404, {"error": "Route introuvable."}, head_only)
            except sqlite3.Error as error:
                print(f"Erreur SQLite pendant GET {path}: {error}")
                self.send_json(500, {"error": "Erreur interne de la base de données."}, head_only)

        def do_POST(self) -> None:
            if urlsplit(self.path).path != "/api/quotes":
                self.send_json(404, {"error": "Route introuvable."})
                return

            content_type = self.headers.get("Content-Type", "")
            if not content_type.lower().startswith("application/json"):
                self.send_json(415, {"error": "Le contenu doit être au format JSON."})
                return

            try:
                body_size = int(self.headers.get("Content-Length", "0"))
            except ValueError:
                self.send_json(400, {"error": "Taille de requête invalide."})
                return
            if body_size <= 0 or body_size > MAX_BODY_SIZE:
                self.send_json(413, {"error": "Taille de requête invalide ou trop importante."})
                return

            try:
                payload = json.loads(self.rfile.read(body_size).decode("utf-8"))
            except (UnicodeDecodeError, json.JSONDecodeError):
                self.send_json(400, {"error": "JSON invalide."})
                return
            if not isinstance(payload, dict):
                self.send_json(400, {"error": "Le corps JSON doit être un objet."})
                return

            customer_name = str(payload.get("customer_name", "")).strip()
            customer_phone = str(payload.get("customer_phone", "")).strip()
            items = payload.get("items")
            if not customer_name or not customer_phone:
                self.send_json(
                    400, {"error": "Le nom et le téléphone du client sont obligatoires."}
                )
                return
            if len(customer_name) > 150 or len(customer_phone) > 50:
                self.send_json(400, {"error": "Les coordonnées du client sont trop longues."})
                return
            if not isinstance(items, list) or not items or len(items) > 200:
                self.send_json(400, {"error": "Le devis doit contenir de 1 à 200 articles."})
                return

            quote_number = str(payload.get("numero", "")).strip()
            if not quote_number or len(quote_number) > 50:
                self.send_json(400, {"error": "Le numéro de devis est invalide."})
                return

            validated_items: list[tuple[int, int]] = []
            for item in items:
                if not isinstance(item, dict):
                    self.send_json(400, {"error": "Un article du devis est invalide."})
                    return
                try:
                    product_id = int(item.get("product_id", 0))
                    quantity = int(item.get("quantite", 0))
                except (TypeError, ValueError):
                    self.send_json(400, {"error": "Produit ou quantité invalide."})
                    return
                if product_id <= 0 or quantity <= 0 or quantity > 10000:
                    self.send_json(400, {"error": "Produit ou quantité invalide."})
                    return
                validated_items.append((product_id, quantity))

            quote_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            try:
                with closing(sqlite3.connect(database_path)) as connection:
                    with connection:
                        connection.execute("PRAGMA foreign_keys = ON")
                        cursor = connection.execute(
                            """
                            INSERT INTO Quotes
                                (numero, date_creation, statut, customer_name, company_name,
                                 customer_phone, customer_email, address, notes)
                            VALUES (?, ?, 'En attente', ?, ?, ?, ?, ?, ?)
                            """,
                            (
                                quote_number,
                                quote_date,
                                customer_name,
                                str(payload.get("company_name", ""))[:150],
                                customer_phone,
                                str(payload.get("customer_email", ""))[:100],
                                str(payload.get("address", ""))[:250],
                                str(payload.get("notes", ""))[:10000],
                            ),
                        )
                        quote_id = cursor.lastrowid

                        for product_id, quantity in validated_items:
                            product = connection.execute(
                                "SELECT nom, reference, prix FROM Product WHERE id = ?",
                                (product_id,),
                            ).fetchone()
                            if product is None:
                                raise ValueError(f"Produit introuvable : {product_id}")
                            connection.execute(
                                """
                                INSERT INTO QuoteItems
                                    (quote_id, product_id, product_name, product_ref,
                                     quantite, prix_unitaire)
                                VALUES (?, ?, ?, ?, ?, ?)
                                """,
                                (
                                    quote_id,
                                    product_id,
                                    product[0],
                                    product[1],
                                    quantity,
                                    product[2],
                                ),
                            )
            except ValueError as error:
                self.send_json(400, {"error": str(error)})
                return
            except sqlite3.IntegrityError:
                self.send_json(409, {"error": "Ce numéro de devis existe déjà."})
                return
            except sqlite3.Error as error:
                print(f"Erreur SQLite pendant POST /api/quotes: {error}")
                self.send_json(500, {"error": "Erreur interne de la base de données."})
                return

            self.send_json(
                201,
                {
                    "id": quote_id,
                    "numero": quote_number,
                    "date_creation": quote_date,
                    "statut": "En attente",
                },
            )

        def do_PUT(self) -> None:
            self.send_json(405, {"error": "Méthode non autorisée."})

        def do_DELETE(self) -> None:
            self.send_json(405, {"error": "Méthode non autorisée."})

    return ApiHandler


def main() -> None:
    database_path = Path(os.environ.get("NGNEX_API_DB_PATH", str(DEFAULT_DB_FILE)))
    port = int(os.environ.get("NGNEX_API_PORT", "8000"))
    initialize_database(database_path)
    host = os.environ.get("NGNEX_API_HOST", "0.0.0.0")
    server = ThreadingHTTPServer((host, port), create_handler(database_path))
    print(f"API NGNEX disponible sur http://127.0.0.1:{port} et sur Wi-Fi (port {port})")
    print(f"Base SQLite : {database_path}")
    print("Serveur local de développement uniquement; ne pas exposer sur Internet.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nArrêt du serveur NGNEX.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
