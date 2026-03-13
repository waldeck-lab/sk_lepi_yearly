# File ./src/init_sqlite_db.py
import sqlite3
import os
from pathlib import Path

ROOT_DIR = Path(os.getenv("SKLEPI_ROOT", Path(__file__).resolve().parents[1]))
DB_PATH = Path(os.getenv("SKLEPI_DB_PATH", ROOT_DIR / "db" / "obsperyear.sqlite"))
SCHEMA_PATH = ROOT_DIR / "sql" / "schema.sql"


def main():
    Path(DB_PATH).parent.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")

    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        schema_sql = f.read()

    conn.executescript(schema_sql)
    conn.commit()
    conn.close()

    print(f"Initialized SQLite DB from schema: {SCHEMA_PATH}")
    print(f"SQLite DB ready: {DB_PATH}")


if __name__ == "__main__":
    main()
