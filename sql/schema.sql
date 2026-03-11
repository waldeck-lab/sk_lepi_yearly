-- file: ./sql/schema.sql 
PRAGMA foreign_keys = ON;

-- =========================================================
-- Tables
-- =========================================================

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

CREATE TABLE IF NOT EXISTS sync_state (
    sync_name TEXT PRIMARY KEY,
    last_run_at TEXT,
    last_skip INTEGER,
    last_total_count INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS species_manual_flags (
    taxon_id INTEGER,
    scientific_name TEXT,
    reason_code TEXT NOT NULL,
    reason_text TEXT NOT NULL,
    priority INTEGER DEFAULT 100,
    note TEXT,
    PRIMARY KEY (taxon_id, reason_code)
);

CREATE TABLE IF NOT EXISTS species_skane_history (
    taxon_id INTEGER PRIMARY KEY,
    scientific_name TEXT,
    first_known_year_in_skane INTEGER,
    first_known_obs_date TEXT,
    note TEXT
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

CREATE TABLE IF NOT EXISTS family_overrides (
    scientific_name TEXT PRIMARY KEY,
    family_name TEXT NOT NULL,
    note TEXT
);

CREATE TABLE IF NOT EXISTS family_names_sv (
    family_name TEXT PRIMARY KEY,
    family_name_sv TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS author_abbrev (
    author_full TEXT PRIMARY KEY,
    author_short TEXT NOT NULL
);

-- =========================================================
-- Indexes
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_obs_taxon ON observations(taxon_id);
CREATE INDEX IF NOT EXISTS idx_obs_date ON observations(observed_at);
CREATE INDEX IF NOT EXISTS idx_obs_municipality ON observations(municipality_id);
CREATE INDEX IF NOT EXISTS idx_obs_sciname ON observations(scientific_name);
CREATE INDEX IF NOT EXISTS idx_obs_common_name ON observations(common_name);
CREATE INDEX IF NOT EXISTS idx_obs_redlist ON observations(red_list_code);
CREATE INDEX IF NOT EXISTS idx_obs_verified ON observations(verified);

CREATE INDEX IF NOT EXISTS idx_taxa_family ON taxa(family_name);
CREATE INDEX IF NOT EXISTS idx_taxa_rank ON taxa(taxon_rank);

-- =========================================================
-- Seed data
-- =========================================================

INSERT OR IGNORE INTO family_names_sv VALUES
('Zygaenidae','Bastardsvärmare'),
('Tortricidae','Vecklare'),
('Noctuidae','Nattflyn'),
('Geometridae','Mätare'),
('Crambidae','Mott'),
('Nymphalidae','Praktfjärilar'),
('Lycaenidae','Blåvingar'),
('Pieridae','Vitfjärilar'),
('Sphingidae','Svärmare');

INSERT OR IGNORE INTO author_abbrev VALUES
('Linnaeus','L.'),
('Linnaé', 'L.'),
('Fabricius','F.'),
('Haworth','Haw.'),
('Hübner','Hb.'),
('Hubner','Hb.'),
('Stainton', 'Stt.'),
('Zeller', 'Zell.'),
('Esper', 'Esp.'),
('Denis & Schiffermüller','D&S'),
('Denis & Schiffenmüller','D&S'),
('Denis & Schiffenmuller','D&S'),
('Scheven','Sch.'),
('Wallengren', 'Wall.'),
('Ochsenheimer', 'Ochs.'),
('Duponchel', 'Dup.'),
('Clerck', 'Cl.'),
('Scopoli', 'Scop.'),
('Freyer', 'Fr.'),
('Müller', 'Müll.'),
('Röber', 'Röb.');

-- =========================================================
-- Views
-- =========================================================

DROP VIEW IF EXISTS v_species_summary_2025;

CREATE VIEW v_species_summary_2025 AS
SELECT
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code,
    COUNT(*) observation_count,
    COUNT(DISTINCT o.municipality_name) municipality_count,
    COUNT(DISTINCT o.reporter) reporter_count,
    SUM(CASE WHEN o.verified=1 THEN 1 ELSE 0 END) verified_count,
    MIN(o.observed_at) first_obs,
    MAX(o.observed_at) last_obs
FROM observations o
LEFT JOIN taxa t ON t.taxon_id=o.taxon_id
WHERE substr(o.observed_at,1,4)='2025'
AND o.scientific_name NOT LIKE '%/%'
AND COALESCE(t.taxon_rank,'')='species'
GROUP BY
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code;

-- =========================================================
-- Author formatting
-- =========================================================

DROP VIEW IF EXISTS v_author_display;

CREATE VIEW v_author_display AS
WITH cleaned AS (
SELECT
    taxon_id,
    scientific_name,
    TRIM(
        CASE
        WHEN instr(REPLACE(REPLACE(author_text,'(',''),')',''),',')>0
        THEN substr(REPLACE(REPLACE(author_text,'(',''),')',''),1,
        instr(REPLACE(REPLACE(author_text,'(',''),')',''),',')-1)
        ELSE REPLACE(REPLACE(author_text,'(',''),')','')
        END
    ) author_clean
FROM taxa
)
SELECT
    c.taxon_id,
    c.scientific_name,
    COALESCE(a.author_short,c.author_clean) author_display
FROM cleaned c
LEFT JOIN author_abbrev a
ON a.author_full=c.author_clean;

-- =========================================================
-- Editorial observation formatting
-- =========================================================

DROP VIEW IF EXISTS v_observation_editorial_2025;

CREATE VIEW v_observation_editorial_2025 AS
SELECT
    o.obs_id,
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.red_list_code,
    o.reporter,
    o.locality,
    o.socken,
    o.source_comment,
    o.individual_count,
    o.observed_at,
    o.verified,

    CASE
        WHEN o.individual_count IS NULL OR TRIM(o.individual_count)=''
        THEN 'noterad'
        ELSE o.individual_count||' ex'
    END count_text,

    CAST(strftime('%d',o.observed_at) AS INTEGER)||'/'||
    CAST(strftime('%m',o.observed_at) AS INTEGER) short_date,

    CASE
        WHEN instr(o.reporter,',')>0
        THEN substr(o.reporter,1,instr(o.reporter,',')-1)
        ELSE o.reporter
    END short_reporter
FROM observations o
LEFT JOIN taxa t ON t.taxon_id=o.taxon_id
WHERE substr(o.observed_at,1,4)='2025'
AND o.scientific_name NOT LIKE '%/%'
AND COALESCE(t.taxon_rank,'')='species';

-- =========================================================
-- Ranking observations
-- =========================================================

DROP VIEW IF EXISTS v_ranked_observations_2025;

CREATE VIEW v_ranked_observations_2025 AS
SELECT
    e.*,
    ROW_NUMBER() OVER(
        PARTITION BY e.taxon_id
        ORDER BY
        CASE WHEN e.source_comment IS NOT NULL THEN 1 ELSE 0 END DESC,
        CASE WHEN e.verified=1 THEN 1 ELSE 0 END DESC,
        e.observed_at ASC
    ) rn
FROM v_observation_editorial_2025 e;

-- =========================================================
-- Report lines
-- =========================================================


DROP VIEW IF EXISTS v_report_lines_2025;

CREATE VIEW v_report_lines_2025 AS
SELECT
    s.scientific_name,

    s.scientific_name||
    CASE WHEN a.author_display IS NOT NULL
         THEN ' ('||a.author_display||')' ELSE '' END||
    CASE WHEN s.common_name IS NOT NULL
         THEN ', '||s.common_name ELSE '' END||
    CASE WHEN s.red_list_code IS NOT NULL
         THEN ', '||s.red_list_code ELSE '' END||
    ': '||
    s.observation_count||
    ' observationer i '||
    s.municipality_count||
    ' kommuner'
    AS report_line

FROM v_species_summary_2025 s
LEFT JOIN v_author_display a
ON a.taxon_id=s.taxon_id

ORDER BY s.scientific_name;
