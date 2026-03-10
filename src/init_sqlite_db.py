import sqlite3

DB_PATH = "obsperyear.sqlite"

SCHEMA = """
CREATE TABLE IF NOT EXISTS observations (
    obs_id TEXT PRIMARY KEY,
    taxon_id INTEGER,
    taxon_sort_order INTEGER,
    red_list_code TEXT,

    common_name TEXT,
    scientific_name TEXT,
    author_text TEXT,

    individual_count TEXT,
    life_stage TEXT,
    sex TEXT,
    method TEXT,

    locality TEXT,
    socken TEXT,
    reporter TEXT,
    reported_by TEXT,

    observed_at TEXT,
    observed_end_at TEXT,
    source_comment TEXT,
    source_dataset TEXT,

    county_id TEXT,
    county_name TEXT,
    municipality_id TEXT,
    municipality_name TEXT,

    decimal_latitude REAL,
    decimal_longitude REAL,
    coordinate_uncertainty_meters REAL,

    verified INTEGER,
    uncertain_identification INTEGER,

    raw_json TEXT,

    imported_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_obs_taxon ON observations(taxon_id);
CREATE INDEX IF NOT EXISTS idx_obs_date ON observations(observed_at);
CREATE INDEX IF NOT EXISTS idx_obs_county ON observations(county_id);
CREATE INDEX IF NOT EXISTS idx_obs_municipality ON observations(municipality_id);
CREATE INDEX IF NOT EXISTS idx_obs_sciname ON observations(scientific_name);
CREATE INDEX IF NOT EXISTS idx_obs_common_name ON observations(common_name);

CREATE TABLE IF NOT EXISTS sync_state (
    sync_name TEXT PRIMARY KEY,
    last_run_at TEXT,
    last_skip INTEGER,
    notes TEXT
);
"""

def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.executescript(SCHEMA)
    conn.commit()
    conn.close()
    print(f"Created or verified SQLite DB: {DB_PATH}")

if __name__ == "__main__":
    main()
