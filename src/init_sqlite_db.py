import sqlite3

DB_PATH = "obsperyear.sqlite"

SCHEMA = """
PRAGMA foreign_keys = ON;

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
    province_id TEXT,
    province_name TEXT,
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
CREATE INDEX IF NOT EXISTS idx_obs_province ON observations(province_id);
CREATE INDEX IF NOT EXISTS idx_obs_municipality ON observations(municipality_id);
CREATE INDEX IF NOT EXISTS idx_obs_sciname ON observations(scientific_name);
CREATE INDEX IF NOT EXISTS idx_obs_common_name ON observations(common_name);
CREATE INDEX IF NOT EXISTS idx_obs_redlist ON observations(red_list_code);
CREATE INDEX IF NOT EXISTS idx_obs_verified ON observations(verified);

CREATE TABLE IF NOT EXISTS sync_state (
    sync_name TEXT PRIMARY KEY,
    last_run_at TEXT,
    last_skip INTEGER,
    last_total_count INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS taxa (
    taxon_id INTEGER PRIMARY KEY,
    accepted_taxon_id INTEGER,
    parent_taxon_id INTEGER,
    scientific_name TEXT,
    author_text TEXT,
    vernacular_name TEXT,
    taxon_rank TEXT,
    family_name TEXT,
    genus_name TEXT,
    species_name TEXT,
    order_name TEXT,
    class_name TEXT,
    phylum_name TEXT,
    kingdom_name TEXT,
    taxonomic_status TEXT,
    raw_json TEXT,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_taxa_family ON taxa(family_name);
CREATE INDEX IF NOT EXISTS idx_taxa_order ON taxa(order_name);
CREATE INDEX IF NOT EXISTS idx_taxa_rank ON taxa(taxon_rank);
CREATE INDEX IF NOT EXISTS idx_taxa_sciname ON taxa(scientific_name);

CREATE TABLE IF NOT EXISTS family_overrides (
    scientific_name TEXT PRIMARY KEY,
    family_name TEXT NOT NULL,
    note TEXT
);

INSERT OR IGNORE INTO family_overrides (scientific_name, family_name, note) VALUES
('Acleris comariana/laterana', 'Tortricidae', 'osäker art inom släktet Acleris'),
('Acleris effractana/emargana', 'Tortricidae', 'osäker art inom släktet Acleris'),
('Acronicta psi/tridens', 'Noctuidae', 'osäker art'),
('Agonopterix ciliella/heracliana', 'Depressariidae', 'osäker art'),
('Amphipoea crinanensis/fucosa/lucens/oculea', 'Noctuidae', 'osäker artkomplex'),
('Argynnis paphia morphotype valesina', 'Nymphalidae', 'morfotyp'),
('Bactra lacteana/lancealana/robustana/suedana', 'Tortricidae', 'osäker artkomplex'),
('Catoptria osthelderi/permutatella', 'Crambidae', 'osäker art'),
('Cnephasia alticolana/asseclana/communana/genitalana/pasiuana', 'Tortricidae', 'osäker artkomplex'),
('Cnephasia asseclana/genitalana/incertana/pasiuana', 'Tortricidae', 'osäker artkomplex'),
('Coleophora alcyonipennella/frischella', 'Coleophoridae', 'osäker art'),
('Diachrysia chrysitis/stenochrysis', 'Noctuidae', 'osäker art'),
('Diarsia florida/rubi', 'Noctuidae', 'osäker art'),
('Eriocrania sangii/semipurpurella', 'Eriocraniidae', 'osäker art'),
('Eupithecia absinthiata/goossensiata', 'Geometridae', 'osäker art'),
('Eupithecia innotata/ochridata', 'Geometridae', 'osäker art'),
('Fabriciana niobe/Fabriciana adippe/Speyeria aglaja', 'Nymphalidae', 'osäker artkomplex'),
('Hadena bicruris/capsincola', 'Noctuidae', 'osäker art'),
('Hemaris/Macroglossum', 'Sphingidae', 'släktesnivå'),
('Limenitis populi/Apatura iris', 'Nymphalidae', 'osäker art'),
('Mesapamea didyma/secalis', 'Noctuidae', 'osäker art'),
('Nymphalis polychloros/xanthomelas', 'Nymphalidae', 'osäker art'),
('Pieris napi/rapae', 'Pieridae', 'osäker art'),
('Plebejus argus/idas', 'Lycaenidae', 'osäker art'),
('Schrankia intermedialis/costaestrigalis', 'Erebidae', 'osäker art'),
('Yponomeuta cagnagellus/malinellus', 'Yponomeutidae', 'osäker art'),
('Zelotherses paleana/unitana', 'Tortricidae', 'osäker art'),
('Zygaena viciae/lonicerae', 'Zygaenidae', 'osäker art');

DROP VIEW IF EXISTS v_species_year_summary;
CREATE VIEW v_species_year_summary AS
SELECT
    substr(o.observed_at, 1, 4) AS obs_year,
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code,
    COUNT(*) AS observation_count,
    COUNT(DISTINCT o.municipality_name) AS municipality_count,
    COUNT(DISTINCT o.reporter) AS reporter_count,
    MIN(o.observed_at) AS first_obs,
    MAX(o.observed_at) AS last_obs,
    SUM(CASE WHEN o.verified = 1 THEN 1 ELSE 0 END) AS verified_count,
    GROUP_CONCAT(DISTINCT o.municipality_name) AS municipalities
FROM observations o
GROUP BY
    substr(o.observed_at, 1, 4),
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code;

DROP VIEW IF EXISTS v_species_summary_2025;
CREATE VIEW v_species_summary_2025 AS
SELECT
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code,
    COUNT(*) AS observation_count,
    COUNT(DISTINCT o.municipality_name) AS municipality_count,
    COUNT(DISTINCT o.reporter) AS reporter_count,
    MIN(o.observed_at) AS first_obs,
    MAX(o.observed_at) AS last_obs,
    SUM(CASE WHEN o.verified = 1 THEN 1 ELSE 0 END) AS verified_count,
    GROUP_CONCAT(DISTINCT o.municipality_name) AS municipalities
FROM observations o
LEFT JOIN taxa t
    ON t.taxon_id = o.taxon_id
WHERE substr(o.observed_at, 1, 4) = '2025'
  AND o.scientific_name NOT LIKE '%/%'
  AND COALESCE(t.taxon_rank, '') = 'species'
GROUP BY
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code;

DROP VIEW IF EXISTS v_uncertain_species_2025;
CREATE VIEW v_uncertain_species_2025 AS
SELECT
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code,
    COUNT(*) AS observation_count,
    COUNT(DISTINCT o.municipality_name) AS municipality_count,
    COUNT(DISTINCT o.reporter) AS reporter_count,
    MIN(o.observed_at) AS first_obs,
    MAX(o.observed_at) AS last_obs,
    SUM(CASE WHEN o.verified = 1 THEN 1 ELSE 0 END) AS verified_count,
    GROUP_CONCAT(DISTINCT o.municipality_name) AS municipalities,
    CASE
        WHEN o.scientific_name LIKE '%/%' THEN 'slash-aggregate'
        WHEN COALESCE(t.taxon_rank, '') <> 'species' THEN 'non-species-rank'
        ELSE 'other'
    END AS uncertain_reason
FROM observations o
LEFT JOIN taxa t
    ON t.taxon_id = o.taxon_id
WHERE substr(o.observed_at, 1, 4) = '2025'
  AND (
        o.scientific_name LIKE '%/%'
        OR COALESCE(t.taxon_rank, '') <> 'species'
      )
GROUP BY
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code;

DROP VIEW IF EXISTS v_family_species_summary_2025;
CREATE VIEW v_family_species_summary_2025 AS
SELECT
    COALESCE(
        t.family_name,
        fo.family_name,
        '[okänd familj]'
    ) AS family_name,
    s.taxon_id,
    s.scientific_name,
    s.common_name,
    s.author_text,
    s.red_list_code,
    s.observation_count,
    s.municipality_count,
    s.reporter_count,
    s.verified_count,
    s.first_obs,
    s.last_obs,
    s.municipalities
FROM v_species_summary_2025 s
LEFT JOIN taxa t
    ON t.taxon_id = s.taxon_id
LEFT JOIN family_overrides fo
    ON fo.scientific_name = s.scientific_name
ORDER BY
    family_name,
    s.scientific_name;

DROP VIEW IF EXISTS v_interesting_species_2025;
CREATE VIEW v_interesting_species_2025 AS
SELECT
    taxon_id,
    scientific_name,
    common_name,
    author_text,
    red_list_code,
    observation_count,
    municipality_count,
    reporter_count,
    verified_count,
    first_obs,
    last_obs,
    municipalities,
    CASE
        WHEN red_list_code IN ('CR', 'EN', 'VU', 'NT') THEN 'Redlist'
        WHEN observation_count <= 3 THEN 'Few observations'
        WHEN verified_count >= 1 THEN 'Verified'
        ELSE 'Other'
    END AS interesting_reason
FROM v_species_summary_2025
WHERE
    red_list_code IN ('CR', 'EN', 'VU', 'NT')
    OR observation_count <= 3
    OR verified_count >= 1
ORDER BY
    CASE red_list_code
        WHEN 'CR' THEN 1
        WHEN 'EN' THEN 2
        WHEN 'VU' THEN 3
        WHEN 'NT' THEN 4
        ELSE 9
    END,
    observation_count ASC,
    scientific_name;

DROP VIEW IF EXISTS v_interesting_family_species_2025;
CREATE VIEW v_interesting_family_species_2025 AS
SELECT
    COALESCE(
        t.family_name,
        fo.family_name,
        '[okänd familj]'
    ) AS family_name,
    s.taxon_id,
    s.scientific_name,
    s.common_name,
    s.author_text,
    s.red_list_code,
    s.observation_count,
    s.municipality_count,
    s.reporter_count,
    s.verified_count,
    s.first_obs,
    s.last_obs,
    s.municipalities,
    CASE
        WHEN s.red_list_code IN ('CR','EN','VU','NT') THEN 'Redlist'
        WHEN s.observation_count <= 3 THEN 'Few observations'
        WHEN s.verified_count >= 1 THEN 'Verified'
        ELSE 'Other'
    END AS interesting_reason
FROM v_species_summary_2025 s
LEFT JOIN taxa t
    ON t.taxon_id = s.taxon_id
LEFT JOIN family_overrides fo
    ON fo.scientific_name = s.scientific_name
WHERE
    s.red_list_code IN ('CR','EN','VU','NT')
    OR s.observation_count <= 3
    OR s.verified_count >= 1
ORDER BY
    family_name,
    CASE s.red_list_code
        WHEN 'CR' THEN 1
        WHEN 'EN' THEN 2
        WHEN 'VU' THEN 3
        WHEN 'NT' THEN 4
        ELSE 9
    END,
    s.observation_count,
    s.scientific_name;
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
