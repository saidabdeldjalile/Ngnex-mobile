#!/usr/bin/env python3
"""Display quotes saved in the local NGNEX API SQLite database."""

import sqlite3
from pathlib import Path


DATABASE_FILE = Path(__file__).resolve().parent / "data" / "ngnex_api.sqlite3"


def main() -> None:
    if not DATABASE_FILE.exists():
        print("La base du serveur n'existe pas encore.")
        print("Démarre d'abord l'API avec : python api\\server.py")
        return

    with sqlite3.connect(DATABASE_FILE) as connection:
        connection.row_factory = sqlite3.Row
        quotes = connection.execute(
            """
            SELECT id, numero, date_creation, statut, customer_name,
                   company_name, customer_phone, customer_email, address, notes
            FROM Quotes
            ORDER BY id DESC
            """
        ).fetchall()

        if not quotes:
            print("Aucun devis enregistré sur le serveur pour le moment.")
            return

        for quote in quotes:
            items = connection.execute(
                """
                SELECT product_name, product_ref, quantite, prix_unitaire
                FROM QuoteItems
                WHERE quote_id = ?
                ORDER BY id
                """,
                (quote["id"],),
            ).fetchall()
            total = sum(item["quantite"] * item["prix_unitaire"] for item in items)

            print(f"\nDevis {quote['numero']} — {quote['date_creation']}")
            print(f"Statut : {quote['statut']}")
            print(f"Client : {quote['customer_name']}")
            if quote["company_name"]:
                print(f"Entreprise : {quote['company_name']}")
            print(f"Téléphone : {quote['customer_phone']}")
            if quote["customer_email"]:
                print(f"E-mail : {quote['customer_email']}")
            if quote["address"]:
                print(f"Adresse : {quote['address']}")
            if quote["notes"]:
                print(f"Message : {quote['notes']}")
            print("Articles :")
            for item in items:
                print(
                    f"  - {item['product_name']} ({item['product_ref']})"
                    f" x {item['quantite']} — "
                    f"{item['quantite'] * item['prix_unitaire']:,.2f} DA"
                )
            print(f"Total indicatif : {total:,.2f} DA")


if __name__ == "__main__":
    main()
