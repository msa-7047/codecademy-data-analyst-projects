
import sqlite3
import csv
from pathlib import Path

# Get the project directory
project_dir = Path(__file__).resolve().parent

# Connect to the SQLite database
conn = sqlite3.connect(project_dir / "climate.db")
cursor = conn.cursor()

# Create the table using schema.sql
cursor.execute("DROP TABLE IF EXISTS state_climate")
with open(project_dir / "schema.sql", encoding="utf-8") as file:
    conn.executescript(file.read())

# Read and import the CSV dataset
with open(project_dir / "state_climate.csv", newline="", encoding="utf-8-sig") as file:
    reader = csv.DictReader(file)

    data = [
        (
            row["state"],
            int(row["year"]),
            float(row["tempf"]),
            float(row["tempc"])
        )
        for row in reader
    ]

# Insert the records into the database
cursor.executemany(
    """
    INSERT INTO state_climate (state, year, tempf, tempc)
    VALUES (?, ?, ?, ?)
    """,
    data
)

conn.commit()

# Verify the number of records
cursor.execute("SELECT COUNT(*) FROM state_climate")
print("Total records:", cursor.fetchone()[0])

# Close the connection
conn.close()
