# File ./src/init_sqlite_db.py
import sqlite3
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "src" / "obsperyear.sqlite"
SCHEMA_PATH = PROJECT_ROOT / "sql" / "schema.sql"

def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        schema_sql = f.read()

    cur.executescript(schema_sql)

    conn.commit()
    conn.close()

    print(f"SQLite DB created or verified: {DB_PATH}")

if __name__ == "__main__":
    main()
