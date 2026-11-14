"""Build the SQLite database from the original CoolTShirts page visit data."""
import csv
import sqlite3
from pathlib import Path

BASE = Path(__file__).resolve().parent
DB = BASE / "marketing_attribution.db"

with sqlite3.connect(DB) as conn:
    conn.executescript((BASE / "schema.sql").read_text(encoding="utf-8"))
    with (BASE / "page_visits.csv").open(newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        records = [
            (row["page_name"], row["timestamp"], int(row["user_id"]),
             row["utm_campaign"], row["utm_source"])
            for row in reader
        ]
    conn.executemany("""INSERT INTO page_visits
        (page_name, timestamp, user_id, utm_campaign, utm_source)
        VALUES (?, ?, ?, ?, ?)""", records)
    print(f"Created {DB.name} with {len(records):,} page visits.")
