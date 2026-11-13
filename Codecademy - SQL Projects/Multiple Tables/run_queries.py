
import sqlite3

# Connect to a local SQLite database
conn = sqlite3.connect(":memory:")

# Read and execute the database schema
with open("schema.sql", encoding="utf-8") as file:
    conn.executescript(file.read())

# Populate the database with sample records
with open("sample_data.sql", encoding="utf-8") as file:
    conn.executescript(file.read())

# Read SQL queries
with open("queries.sql", encoding="utf-8") as file:
    queries = file.read()

# Execute each query and display its results
cursor = conn.cursor()

for query in queries.split(";"):
    query = query.strip()

    if query:
        cursor.execute(query)

        print("\nQuery:", query)
        for row in cursor.fetchall():
            print(row)

conn.close()
