import csv
import sqlite3
from pathlib import Path

project_dir = Path(__file__).resolve().parent

with sqlite3.connect(project_dir / "warby_parker.db") as conn:
    conn.executescript("""
        DROP TABLE IF EXISTS survey;
        DROP TABLE IF EXISTS quiz;
        DROP TABLE IF EXISTS home_try_on;
        DROP TABLE IF EXISTS purchase;
    """)
    conn.executescript((project_dir / "schema.sql").read_text(encoding="utf-8"))

    for table in ("survey", "quiz", "home_try_on", "purchase"):
        with (project_dir / f"{table}.csv").open(newline="", encoding="utf-8-sig") as file:
            reader = csv.DictReader(file)
            columns = reader.fieldnames
            placeholders = ", ".join("?" for _ in columns)
            column_names = ", ".join(columns)
            rows = ([row[column] for column in columns] for row in reader)
            conn.executemany(
                f"INSERT INTO {table} ({column_names}) VALUES ({placeholders})",
                rows,
            )
        count = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"{table}: {count} rows")
