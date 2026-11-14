"""Create a local SQLite database from the provided Twitch CSV exports."""
import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "twitch_gaming_trends.db"


def main():
    with sqlite3.connect(DB_PATH) as conn:
        conn.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))
        for table, filename, columns in [
            ("stream", "stream.csv", 9),
            ("chat", "chat.csv", 7),
        ]:
            with (ROOT / filename).open(newline="", encoding="utf-8-sig") as handle:
                reader = csv.reader(handle)
                next(reader)
                rows = [tuple(value if value != "" else None for value in row)
                        for row in reader]
            placeholders = ", ".join("?" for _ in range(columns))
            conn.executemany(f"INSERT INTO {table} VALUES ({placeholders})", rows)
            print(f"Imported {len(rows):,} rows into {table}")
    print(f"Database created: {DB_PATH}")


if __name__ == "__main__":
    main()
