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
    observed_at TEXT,
    source_comment TEXT,
    source_dataset TEXT,
    county_id TEXT,
    county_name TEXT,
    municipality_id TEXT,
    municipality_name TEXT,
    decimal_latitude REAL,
    decimal_longitude REAL,
    verified INTEGER,
    uncertain_identification INTEGER,
    imported_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_obs_taxon ON observations(taxon_id);
CREATE INDEX IF NOT EXISTS idx_obs_date ON observations(observed_at);
CREATE INDEX IF NOT EXISTS idx_obs_county ON observations(county_id);
CREATE INDEX IF NOT EXISTS idx_obs_sciname ON observations(scientific_name);
