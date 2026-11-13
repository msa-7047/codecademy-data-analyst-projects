"""Create a local SQLite database using the original Codeflix dataset."""
import csv
import sqlite3
from pathlib import Path

project_dir = Path(__file__).resolve().parent
connection = sqlite3.connect(project_dir / "churn.db")

try:
    with connection:
        connection.execute("DROP TABLE IF EXISTS subscriptions")
        connection.executescript((project_dir / "schema.sql").read_text(encoding="utf-8"))

        with (project_dir / "subscriptions.csv").open(newline="", encoding="utf-8-sig") as file:
            reader = csv.DictReader(file)
            records = [
                (
                    int(row["id"]),
                    row["subscription_start"],
                    row["subscription_end"] or None,
                    int(row["segment"]),
                )
                for row in reader
            ]

        connection.executemany(
            """INSERT INTO subscriptions
               (id, subscription_start, subscription_end, segment)
               VALUES (?, ?, ?, ?)""",
            records,
        )

    count = connection.execute("SELECT COUNT(*) FROM subscriptions").fetchone()[0]
    print(f"Database created: {project_dir / 'churn.db'}")
    print(f"Total subscriptions: {count}")
finally:
    connection.close()
