-- file: ./sql/schema.sql
PRAGMA foreign_keys = ON;
BEGIN; 
-- =========================================================
-- TABLES
-- =========================================================

CREATE TABLE IF NOT EXISTS observations (
    obs_id TEXT PRIMARY KEY,
    taxon_id INTEGER,
    taxon_sort_order INTEGER,
    red_list_code TEXT,

    common_name TEXT,
    scientific_name TEXT,
    author_text TEXT,

    individual_count REAL,
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
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (taxon_id) REFERENCES taxa(taxon_id)
);

CREATE TABLE IF NOT EXISTS sync_state (
    sync_name TEXT PRIMARY KEY,
    last_run_at TEXT,
    last_skip INTEGER,
    last_total_count INTEGER,
    notes TEXT,
    last_error TEXT
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
    taxon_lsid TEXT UNIQUE,
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
    nomenclatural_status TEXT,
    taxon_remarks TEXT,
    raw_json TEXT,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (accepted_taxon_id) REFERENCES taxa(taxon_id),
    FOREIGN KEY (parent_taxon_id) REFERENCES taxa(taxon_id)
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
-- INDEXES
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_obs_taxon ON observations(taxon_id);
CREATE INDEX IF NOT EXISTS idx_obs_date ON observations(observed_at);
CREATE INDEX IF NOT EXISTS idx_obs_county ON observations(county_id);
CREATE INDEX IF NOT EXISTS idx_obs_province ON observations(province_id);
CREATE INDEX IF NOT EXISTS idx_obs_municipality ON observations(municipality_id);
CREATE INDEX IF NOT EXISTS idx_obs_sciname ON observations(scientific_name);
CREATE INDEX IF NOT EXISTS idx_obs_common_name ON observations(common_name);
CREATE INDEX IF NOT EXISTS idx_obs_redlist ON observations(red_list_code);
CREATE INDEX IF NOT EXISTS idx_obs_verified ON observations(verified);
CREATE INDEX IF NOT EXISTS idx_obs_taxon_date ON observations(taxon_id, observed_at);
CREATE INDEX IF NOT EXISTS idx_obs_taxon_verified ON observations(taxon_id, verified);
CREATE INDEX IF NOT EXISTS idx_obs_taxon_sort_order ON observations(taxon_sort_order);
CREATE INDEX IF NOT EXISTS idx_obs_year_taxon ON observations(observed_at, taxon_id);

CREATE INDEX IF NOT EXISTS idx_taxa_family ON taxa(family_name);
CREATE INDEX IF NOT EXISTS idx_taxa_order ON taxa(order_name);
CREATE INDEX IF NOT EXISTS idx_taxa_rank ON taxa(taxon_rank);
CREATE INDEX IF NOT EXISTS idx_taxa_sciname ON taxa(scientific_name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_taxa_lsid ON taxa(taxon_lsid);
CREATE INDEX IF NOT EXISTS idx_taxa_status ON taxa(taxonomic_status);
CREATE INDEX IF NOT EXISTS idx_taxa_accepted_taxon_id ON taxa(accepted_taxon_id);
CREATE INDEX IF NOT EXISTS idx_taxa_parent_taxon_id ON taxa(parent_taxon_id);

-- =========================================================
-- Alter tables
-- =========================================================

-- =========================================================
-- SEED DATA
-- =========================================================

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

INSERT OR IGNORE INTO family_names_sv (family_name, family_name_sv) VALUES
('Nymphalidae', 'Praktfjärilar'),
('Psychidae', 'Säckspinnare'),
('Limacodidae', 'Snigelspinnare'),
('Bucculatricidae', 'Kronmalar'),
('Gracillariidae', 'Styltmalar & guldmalar'),
('Nepticulidae', 'Dvärgmalar'),
('Ypsolophidae', 'Tandmalar'),
('Zygaenidae', 'Bastardsvärmare'),
('Tortricidae', 'Vecklare'),
('Noctuidae', 'Nattflyn'),
('Geometridae', 'Mätare'),
('Crambidae', 'Mott'),
('Erebidae', 'Björkspinnare & lappmätare'),
('Depressariidae', 'Plattmalar'),
('Coleophoridae', 'Säckmalar'),
('Eriocraniidae', 'Purpurmalar'),
('Sphingidae', 'Svärmare'),
('Pieridae', 'Vitfjärilar'),
('Lycaenidae', 'Blåvingar'),
('Yponomeutidae', 'Spinnmalar'),
('Adelidae', 'Antennmalar'),
('Heliozelidae', 'Hålmalar'),
('Incurvariidae', 'Bladskärare'),
('Prodoxidae', 'Knoppmalar'),
('Choreutidae', 'Gnidmott'),
('Douglasiidae', 'Skäckmalar'),
('Epermeniidae', 'Skärmmalar'),
('Momphidae', 'Dunörtsmalar'),
('Parametriotidae', 'Brokmalar'),
('Scythrididae', 'Fältmalar'),
('Lypusidae', 'Tubmalar'),
('Argyresthiidae', 'Hängemalar'),
('Glyphipterigidae', 'Hakmalar'),
('Lyonetiidae', 'Lansettmalar'),
('Plutellidae', 'Korsblommalar');

INSERT OR IGNORE INTO author_abbrev (author_full, author_short) VALUES
('Linnaeus', 'L.'),
('Linnaé', 'L.'),
('Fabricius', 'F.'),
('Haworth', 'Haw.'),
('Hübner', 'Hb.'),
('Hubner', 'Hb.'),
('Stainton', 'Stt.'),
('Zeller', 'Zell.'),
('Treitschke', 'Tr.'),
('Esper', 'Esp.'),
('Denis & Schiffermüller', 'D&S'),
('Denis & Schiffenmüller', 'D&S'),
('Denis & Schiffenmuller', 'D&S'),
('Scheven', 'Sch.'),
('Wallengren', 'Wall.'),
('Ochsenheimer', 'Ochs.'),
('Duponchel', 'Dup.'),
('Clerck', 'Cl.'),
('Scopoli', 'Scop.'),
('Freyer', 'Fr.'),
('Müller', 'Müll.'),
('Röber', 'Röb.');

-- Dessa skall infogas manuellt via separat fil
-- INSERT OR IGNORE INTO species_skane_history
-- (taxon_id, scientific_name, first_known_year_in_skane, note)
-- VALUES
-- (6010429, 'Agrochola lunosa', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (214165, 'Argyresthia ivella', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (6332812, 'Caloptilia honoratella', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (216027, 'Chloantha hyperici', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (100636, 'Chrysoclista lathamella', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (214458, 'Coleophora juncicolella', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (6011700, 'Diplopseustis perieresalis', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (6332811, 'Epiblema turbidana', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (216289, 'Euxoa ochrogaster', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025'),
-- (214233, 'Lyonetia ledi', 2025, 'Ny i jämförelse 1900-2024 vs 1900-2025');



-- =========================================================
-- App parameter (year) 
-- =========================================================
CREATE TABLE IF NOT EXISTS app_config (
    config_key TEXT PRIMARY KEY,
    config_value TEXT NOT NULL
);

INSERT OR IGNORE INTO app_config (config_key, config_value)
VALUES ('report_year', '2025');

-- #  v_report_year
DROP VIEW IF EXISTS v_report_year;
CREATE VIEW v_report_year AS
SELECT CAST(config_value AS INTEGER) AS report_year
FROM app_config
WHERE config_key = 'report_year';


-- =========================================================
-- Config table
-- =========================================================
CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);



-- =========================================================
-- Sorting views
-- =========================================================

-- #  v_family_sort_order
DROP VIEW IF EXISTS v_family_sort_order;
CREATE VIEW v_family_sort_order AS
SELECT
    family_name,
    MIN(taxon_sort_order) AS family_sort_order
FROM v_interesting_family_species
GROUP BY family_name;

-- =========================================================
-- Date spans (for large sets of observations)
-- =========================================================

-- #  v_species_date_span
DROP VIEW IF EXISTS v_species_date_span;
CREATE VIEW v_species_date_span AS
SELECT
    taxon_id,
    MIN(observed_at) AS first_observed_at,
    MAX(observed_at) AS last_observed_at,
    CAST(strftime('%d', substr(MIN(observed_at),1,19)) AS INTEGER) || '/' ||
    CAST(strftime('%m', substr(MIN(observed_at),1,19)) AS INTEGER) AS first_date,
    CAST(strftime('%d', substr(MAX(observed_at),1,19)) AS INTEGER) || '/' ||
    CAST(strftime('%m', substr(MAX(observed_at),1,19)) AS INTEGER) AS last_date
FROM observations o
JOIN v_report_year y
WHERE substr(o.observed_at,1,4) = CAST(y.report_year AS TEXT)
GROUP BY taxon_id;

-- =========================================================
-- CORE VIEWS
-- =========================================================

-- #  v_species_year_summary
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


-- #  v_species_summary
DROP VIEW IF EXISTS v_species_summary;

CREATE VIEW v_species_summary AS
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
    substr(o.observed_at, 1, 4) AS obs_year
FROM observations o
LEFT JOIN taxa t
    ON t.taxon_id = o.taxon_id
JOIN v_report_year y
WHERE substr(o.observed_at, 1, 4) = CAST(y.report_year AS TEXT)
  AND o.scientific_name NOT LIKE '%/%'
  AND COALESCE(t.taxon_rank, '') = 'species'
GROUP BY
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code,
    substr(o.observed_at, 1, 4);
    
-- #  v_uncertain_species
DROP VIEW IF EXISTS v_uncertain_species;
CREATE VIEW v_uncertain_species AS
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
    END AS uncertain_reason,
    substr(o.observed_at, 1, 4) AS obs_year
FROM observations o
LEFT JOIN taxa t
    ON t.taxon_id = o.taxon_id
JOIN v_report_year y
WHERE substr(o.observed_at, 1, 4) = CAST(y.report_year AS TEXT)
  AND (
        o.scientific_name LIKE '%/%'
        OR COALESCE(t.taxon_rank, '') <> 'species'
      )
GROUP BY
    o.taxon_id,
    o.scientific_name,
    o.common_name,
    o.author_text,
    o.red_list_code,
    substr(o.observed_at, 1, 4);

-- #  v_family_species_summary
DROP VIEW IF EXISTS v_family_species_summary;
CREATE VIEW v_family_species_summary AS
SELECT
    COALESCE(t.family_name, fo.family_name, '[okänd familj]') AS family_name,
    MIN(o.taxon_sort_order) AS taxon_sort_order,
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
FROM v_species_summary s
JOIN observations o
    ON o.taxon_id = s.taxon_id
LEFT JOIN taxa t
    ON t.taxon_id = s.taxon_id
LEFT JOIN family_overrides fo
    ON fo.scientific_name = s.scientific_name
JOIN v_report_year y
WHERE substr(o.observed_at,1,4) = CAST(y.report_year AS TEXT)
GROUP BY
    COALESCE(t.family_name, fo.family_name, '[okänd familj]'),
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
    s.municipalities;
    
-- =========================================================
-- REASON FLAGS
-- =========================================================

-- #  v_all_species_reason_flags
DROP VIEW IF EXISTS v_all_species_reason_flags;
CREATE VIEW v_all_species_reason_flags AS
SELECT
    taxon_id,
    scientific_name,
    reason_code,
    reason_text,
    priority
FROM v_species_reason_flags

UNION ALL

SELECT
    m.taxon_id,
    m.scientific_name,
    m.reason_code,
    m.reason_text,
    m.priority
FROM species_manual_flags m;


-- #  v_first_in_skane
DROP VIEW IF EXISTS v_first_in_skane;
CREATE VIEW v_first_in_skane AS
SELECT
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
    'first_in_skane' AS reason_code,
    'Första kända fyndet i Skåne infaller under valt rapportår' AS reason_text,
    10 AS priority
FROM v_species_summary s
JOIN species_skane_history h
    ON h.taxon_id = s.taxon_id
JOIN v_report_year y
WHERE h.first_known_year_in_skane = y.report_year;

-- #  v_species_reason_flags
DROP VIEW IF EXISTS v_species_reason_flags;
CREATE VIEW v_species_reason_flags AS
SELECT
    s.taxon_id,
    s.scientific_name,
    'redlist' AS reason_code,
    'Rödlistad art' AS reason_text,
    CASE s.red_list_code
        WHEN 'CR' THEN 1
        WHEN 'EN' THEN 2
        WHEN 'VU' THEN 3
        WHEN 'NT' THEN 4
        ELSE 100
    END AS priority
FROM v_species_summary s
WHERE s.red_list_code IN ('CR','EN','VU','NT')

UNION ALL

SELECT
    s.taxon_id,
    s.scientific_name,
    'few_observations' AS reason_code,
    'Få observationer under året' AS reason_text,
    40 AS priority
FROM v_species_summary s
WHERE s.observation_count <= 3

UNION ALL

SELECT
    s.taxon_id,
    s.scientific_name,
    'verified' AS reason_code,
    'Minst en verifierad observation' AS reason_text,
    60 AS priority
FROM v_species_summary s
WHERE s.verified_count >= 1

UNION ALL

SELECT
    f.taxon_id,
    f.scientific_name,
    f.reason_code,
    f.reason_text,
    f.priority
FROM v_first_in_skane f;


-- #  v_interresting_species
DROP VIEW IF EXISTS v_interesting_species;
CREATE VIEW v_interesting_species AS
SELECT
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
    GROUP_CONCAT(DISTINCT r.reason_code) AS reason_codes,
    GROUP_CONCAT(DISTINCT r.reason_text) AS reason_texts,
    MIN(r.priority) AS top_priority
FROM v_species_summary s
JOIN v_all_species_reason_flags r
    ON r.taxon_id = s.taxon_id
GROUP BY
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
ORDER BY
    top_priority,
    s.scientific_name;

-- #  v_interresting_family_species
DROP VIEW IF EXISTS v_interesting_family_species;
CREATE VIEW v_interesting_family_species AS
SELECT
    COALESCE(t.family_name, fo.family_name, '[okänd familj]') AS family_name,
    MIN(o.taxon_sort_order) AS taxon_sort_order,
    i.taxon_id,
    i.scientific_name,
    i.common_name,
    i.author_text,
    i.red_list_code,
    i.observation_count,
    i.municipality_count,
    i.reporter_count,
    i.verified_count,
    i.first_obs,
    i.last_obs,
    i.municipalities,
    i.reason_codes,
    i.reason_texts,
    i.top_priority
FROM v_interesting_species i
JOIN observations o
    ON o.taxon_id = i.taxon_id
LEFT JOIN taxa t
    ON t.taxon_id = i.taxon_id
LEFT JOIN family_overrides fo
    ON fo.scientific_name = i.scientific_name
JOIN v_report_year y
WHERE substr(o.observed_at,1,4) = CAST(y.report_year AS TEXT)
GROUP BY
    COALESCE(t.family_name, fo.family_name, '[okänd familj]'),
    i.taxon_id,
    i.scientific_name,
    i.common_name,
    i.author_text,
    i.red_list_code,
    i.observation_count,
    i.municipality_count,
    i.reporter_count,
    i.verified_count,
    i.first_obs,
    i.last_obs,
    i.municipalities,
    i.reason_codes,
    i.reason_texts,
    i.top_priority;

-- =========================================================
-- AUTHOR DISPLAY
-- =========================================================

-- #  v_author_display
DROP VIEW IF EXISTS v_author_display;
CREATE VIEW v_author_display AS
WITH author_base AS (
    SELECT
        t.taxon_id,
        t.scientific_name,
        t.author_text AS author_raw,
        TRIM(
            REPLACE(
                REPLACE(COALESCE(t.author_text, ''), '(', ''),
                ')', ''
            )
        ) AS author_no_paren
    FROM taxa t
),
author_clean AS (
    SELECT
        taxon_id,
        scientific_name,
        author_raw,
        author_no_paren,
        TRIM(
            CASE
                WHEN instr(author_no_paren, ',') > 0
                THEN substr(author_no_paren, 1, instr(author_no_paren, ',') - 1)
                ELSE author_no_paren
            END
        ) AS author_normalized
    FROM author_base
)
SELECT
    c.taxon_id,
    c.scientific_name,
    c.author_raw,
    c.author_normalized,
    COALESCE(a.author_short, c.author_normalized) AS author_display
FROM author_clean c
LEFT JOIN author_abbrev a
    ON a.author_full = c.author_normalized;

-- =========================================================
-- EDITORIAL OBSERVATION TEXT
-- =========================================================

-- #  v_observation_editorial
DROP VIEW IF EXISTS v_observation_editorial;
CREATE VIEW v_observation_editorial AS
WITH base AS (
    SELECT
        o.obs_id,
        o.taxon_id,
        COALESCE(t.family_name, fo.family_name, '[okänd familj]') AS family_name,
        COALESCE(fsv.family_name_sv, '') AS family_name_sv,
        o.scientific_name,
        ad.author_display AS author_short,
        o.common_name,
        o.red_list_code,
        o.reporter,
        o.locality,
        CASE
            WHEN o.locality IS NULL THEN NULL
            WHEN TRIM(o.locality) LIKE '%, Sk' THEN TRIM(substr(TRIM(o.locality), 1, length(TRIM(o.locality)) - 4))
            ELSE TRIM(o.locality)
        END AS locality_clean,
        o.socken,
        CASE
            WHEN o.socken IS NULL THEN NULL
            WHEN TRIM(o.socken) LIKE 'Sk,%' THEN TRIM(substr(TRIM(o.socken), 4))
            ELSE TRIM(o.socken)
        END AS socken_clean,
        o.source_comment,
        o.individual_count,
        o.observed_at,
        o.verified
    FROM observations o
    LEFT JOIN taxa t
        ON t.taxon_id = o.taxon_id
    LEFT JOIN family_overrides fo
        ON fo.scientific_name = o.scientific_name
    LEFT JOIN family_names_sv fsv
        ON fsv.family_name = COALESCE(t.family_name, fo.family_name)
    LEFT JOIN v_author_display ad
        ON ad.taxon_id = o.taxon_id
    JOIN v_report_year y
    WHERE substr(o.observed_at,1,4) = CAST(y.report_year AS TEXT)
      AND o.scientific_name NOT LIKE '%/%'
      AND COALESCE(t.taxon_rank, '') = 'species'
),
normed AS (
    SELECT
        *,
        LOWER(TRIM(REPLACE(REPLACE(REPLACE(COALESCE(locality_clean,''), '.', ''), ',', ''), '  ', ' '))) AS locality_norm,
        LOWER(TRIM(REPLACE(REPLACE(REPLACE(COALESCE(socken_clean,''), '.', ''), ',', ''), '  ', ' '))) AS socken_norm
    FROM base
),
prepared AS (
    SELECT
        *,
	CASE
		WHEN individual_count IS NULL THEN 'noterad'
    		WHEN individual_count = CAST(individual_count AS INTEGER)
        	     THEN printf('%d ex', CAST(individual_count AS INTEGER))
    		ELSE printf('%g ex', individual_count)
	END AS count_text,
        CASE
            WHEN individual_count IS NULL OR TRIM(individual_count) = '' THEN 'noterad'
            ELSE TRIM(individual_count) || ' ex'
        END AS count_text,

        CAST(strftime('%d', substr(observed_at,1,19)) AS INTEGER) || '/' ||
        CAST(strftime('%m', substr(observed_at,1,19)) AS INTEGER) AS short_date,

        CASE
            WHEN reporter IS NULL OR TRIM(reporter) = '' THEN '[okänd rapportör]'
            WHEN instr(reporter, ',') > 0 THEN TRIM(substr(reporter, 1, instr(reporter, ',') - 1))
            ELSE TRIM(reporter)
        END AS short_reporter,

        CASE
            WHEN locality_clean IS NOT NULL
                 AND instr(locality_clean, ',') > 0
                 AND LOWER(TRIM(substr(locality_clean, 1, instr(locality_clean, ',') - 1)))
                     = LOWER(TRIM(substr(locality_clean, instr(locality_clean, ',') + 1)))
            THEN TRIM(substr(locality_clean, 1, instr(locality_clean, ',') - 1))

            WHEN locality_clean IS NOT NULL AND TRIM(locality_clean) <> ''
            THEN TRIM(locality_clean)

            ELSE ''
        END AS locality_display,

        CASE
            WHEN locality_clean IS NOT NULL
                 AND instr(locality_clean, ',') > 0
                 AND LOWER(TRIM(substr(locality_clean, 1, instr(locality_clean, ',') - 1)))
                     = LOWER(TRIM(substr(locality_clean, instr(locality_clean, ',') + 1)))
            THEN
                CASE
                    WHEN socken_clean IS NOT NULL AND TRIM(socken_clean) <> ''
                         AND LOWER(TRIM(substr(locality_clean, 1, instr(locality_clean, ',') - 1))) <> LOWER(TRIM(socken_clean))
                    THEN TRIM(substr(locality_clean, 1, instr(locality_clean, ',') - 1)) || ', ' || TRIM(socken_clean)
                    ELSE TRIM(substr(locality_clean, 1, instr(locality_clean, ',') - 1))
                END

            WHEN locality_clean IS NOT NULL AND TRIM(locality_clean) <> ''
                 AND socken_clean IS NOT NULL AND TRIM(socken_clean) <> ''
                 AND locality_norm <> socken_norm
                 AND instr(locality_norm, socken_norm) = 0
            THEN TRIM(locality_clean) || ', ' || TRIM(socken_clean)

            WHEN locality_clean IS NOT NULL AND TRIM(locality_clean) <> ''
            THEN TRIM(locality_clean)

            WHEN socken_clean IS NOT NULL AND TRIM(socken_clean) <> ''
            THEN TRIM(socken_clean)

            ELSE ''
        END AS place_text
    FROM normed
)
SELECT
    obs_id,
    taxon_id,
    family_name,
    family_name_sv,
    scientific_name,
    author_short,
    common_name,
    red_list_code,
    reporter,
    locality,
    locality_clean,
    socken,
    socken_clean,
    source_comment,
    individual_count,
    observed_at,
    verified,
    count_text,
    short_date,
    short_reporter,
    locality_display,
    place_text,
    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            (
                                count_text
                                || ', ' || short_date
                                || ', ' || short_reporter
                                || CASE
                                    WHEN place_text <> ''
                                    THEN ', ' || place_text
                                    ELSE ''
                                   END
                                || CASE
                                    WHEN source_comment IS NOT NULL
                                     AND TRIM(source_comment) <> ''
                                     AND length(TRIM(source_comment)) <= 120
                                    THEN ', ' || TRIM(source_comment)
                                    ELSE ''
                                   END
                            ),
                            ', ,', ', '
                        ),
                        ',,', ','
                    ),
                    ', .', '.'
                ),
                '  ', ' '
            ),
            ' ,', ','
        )
    ) AS obs_text

FROM prepared;

-- #  v_observation_editorial_dedup
DROP VIEW IF EXISTS v_observation_editorial_dedup;
CREATE VIEW v_observation_editorial_dedup AS
WITH base AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                e.taxon_id,
                e.obs_text
            ORDER BY
                CASE WHEN e.source_comment IS NOT NULL AND TRIM(e.source_comment) <> '' THEN 1 ELSE 0 END DESC,
                CASE WHEN e.verified = 1 THEN 1 ELSE 0 END DESC,
                e.obs_id
        ) AS dup_rn
    FROM v_observation_editorial e
)
SELECT *
FROM base
WHERE dup_rn = 1;

-- #  v_ranked_observations
DROP VIEW IF EXISTS v_ranked_observations;
CREATE VIEW v_ranked_observations AS
SELECT
    e.*,
    (
        CASE WHEN e.source_comment IS NOT NULL AND TRIM(e.source_comment) <> '' THEN 100 ELSE 0 END +
        CASE WHEN e.verified = 1 THEN 40 ELSE 0 END +
        CASE WHEN e.individual_count IS NOT NULL AND TRIM(e.individual_count) <> '' THEN 20 ELSE 0 END
    ) AS quality_score,
    ROW_NUMBER() OVER (
        PARTITION BY e.taxon_id
        ORDER BY
            CASE WHEN e.source_comment IS NOT NULL AND TRIM(e.source_comment) <> '' THEN 1 ELSE 0 END DESC,
            CASE WHEN e.verified = 1 THEN 1 ELSE 0 END DESC,
            CASE WHEN e.individual_count IS NOT NULL AND TRIM(e.individual_count) <> '' THEN 1 ELSE 0 END DESC,
            e.observed_at ASC,
            e.obs_id
    ) AS rn
FROM v_observation_editorial_dedup e;

-- #  v_report_observations
DROP VIEW IF EXISTS v_report_observations;
CREATE VIEW v_report_observations AS
SELECT
    taxon_id,
    obs_text,
    observed_at
FROM v_ranked_observations
WHERE rn <= 5
ORDER BY
    taxon_id,
    observed_at;


-- #  v_obs_concat
DROP VIEW IF EXISTS v_obs_concat;
CREATE VIEW v_obs_concat AS
SELECT
    taxon_id,
    GROUP_CONCAT(TRIM(obs_text), '; ') AS obs_texts
FROM (
    SELECT *
    FROM v_ranked_observations
    WHERE rn <= 3
    ORDER BY taxon_id, observed_at
)
GROUP BY taxon_id;


-- =========================================================
-- REPORT VIEWS
-- =========================================================

-- #  v_report_draft
DROP VIEW IF EXISTS v_report_draft;

CREATE VIEW v_report_draft AS
WITH base AS (
    SELECT
        i.family_name,
        COALESCE(fsv.family_name_sv, '') AS family_name_sv,
        i.taxon_sort_order,
        i.taxon_id,
        i.scientific_name,
        COALESCE(ad.author_display, i.author_text) AS author_short,
        i.common_name,
        i.red_list_code,
        i.observation_count,
        i.municipality_count,
        i.reason_codes,
        i.reason_texts,
        i.top_priority,
        i.verified_count,
        oc.obs_texts,
        ds.first_date,
        ds.last_date,

	CASE
		WHEN instr(COALESCE(i.reason_codes, ''), 'first_in_skane') > 0 THEN 1
    		ELSE 0
	END AS has_first_in_skane,
	-- CASE
        --     WHEN instr(COALESCE(i.reason_codes, ''), 'first_in_skane') > 0
        --       OR instr(COALESCE(i.reason_codes, ''), 'first_province') > 0
        --       OR instr(COALESCE(i.reason_texts, ''), 'Första kända fyndet i Skåne') > 0
        --     THEN 1
        --     ELSE 0
        -- END AS has_first_in_skane,

        CASE
            WHEN i.red_list_code IN ('CR', 'EN', 'VU', 'NT') THEN 1
            ELSE 0
        END AS has_redlist,

        CASE
            WHEN i.observation_count <= 3 THEN 1
            ELSE 0
        END AS has_few_observations
    FROM v_interesting_family_species i
    LEFT JOIN v_obs_concat oc
        ON oc.taxon_id = i.taxon_id
    LEFT JOIN family_names_sv fsv
        ON fsv.family_name = i.family_name
    LEFT JOIN v_author_display ad
        ON ad.taxon_id = i.taxon_id
    LEFT JOIN v_species_date_span ds
        ON ds.taxon_id = i.taxon_id
)
SELECT
    family_name,
    family_name_sv,
    taxon_sort_order,
    taxon_id,
    scientific_name,
    author_short,
    common_name,
    red_list_code,
    observation_count,
    municipality_count,
    reason_codes,
    reason_texts,
    top_priority,

    CASE
        WHEN observation_count <= 5 THEN obs_texts
        ELSE NULL
    END AS obs_data,

    CASE
        WHEN observation_count > 5 THEN
            CAST(observation_count AS TEXT) || ' observationer i ' ||
            CASE
                WHEN municipality_count = 1 THEN '1 kommun'
                ELSE CAST(municipality_count AS TEXT) || ' kommuner'
            END ||
            CASE
                WHEN first_date IS NOT NULL AND last_date IS NOT NULL THEN
                    CASE
                        WHEN first_date = last_date
                        THEN ' (' || first_date || ')'
                        ELSE ' (' || first_date || '–' || last_date || ')'
                    END
                ELSE ''
            END ||
            CASE
                WHEN has_first_in_skane = 1 OR has_redlist = 1 THEN
                    '. ' ||
                    TRIM(
                        CASE
                            WHEN has_first_in_skane = 1
                            THEN 'Första kända fyndet i Skåne infaller under valt rapportår'
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_first_in_skane = 1 AND has_redlist = 1
                            THEN '. '
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_redlist = 1
                            THEN 'Rödlistad art'
                            ELSE ''
                        END
                    )
                ELSE ''
            END

        WHEN observation_count <= 3 THEN
            NULLIF(
                TRIM(
                    CASE
                        WHEN has_first_in_skane = 1
                        THEN 'Första kända fyndet i Skåne infaller under valt rapportår'
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_first_in_skane = 1 AND has_redlist = 1
                        THEN '. '
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_redlist = 1
                        THEN 'Rödlistad art'
                        ELSE ''
                    END ||
                    CASE
                        WHEN (has_first_in_skane = 1 OR has_redlist = 1) AND has_few_observations = 1
                        THEN '. '
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_few_observations = 1
                        THEN 'Få observationer under året'
                        ELSE ''
                    END
                ),
                ''
            )

        WHEN observation_count <= 5 THEN
            CASE
                WHEN first_date IS NOT NULL AND last_date IS NOT NULL THEN
                    CASE
                        WHEN first_date = last_date
                        THEN '(' || first_date || ')'
                        ELSE '(' || first_date || '–' || last_date || ')'
                    END
                ELSE ''
            END ||
            CASE
                WHEN has_first_in_skane = 1 OR has_redlist = 1 THEN
                    CASE
                        WHEN first_date IS NOT NULL AND last_date IS NOT NULL
                        THEN '. '
                        ELSE ''
                    END ||
                    TRIM(
                        CASE
                            WHEN has_first_in_skane = 1
                            THEN 'Första kända fyndet i Skåne infaller under valt rapportår'
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_first_in_skane = 1 AND has_redlist = 1
                            THEN '. '
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_redlist = 1
                            THEN 'Rödlistad art'
                            ELSE ''
                        END
                    )
                ELSE ''
            END

        ELSE
            NULLIF(
                TRIM(
                    CASE
                        WHEN has_first_in_skane = 1
                        THEN 'Första kända fyndet i Skåne infaller under valt rapportår'
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_first_in_skane = 1 AND has_redlist = 1
                        THEN '. '
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_redlist = 1
                        THEN 'Rödlistad art'
                        ELSE ''
                    END
                ),
                ''
            )
    END AS closing_comment

FROM base
GROUP BY
    family_name,
    family_name_sv,
    taxon_sort_order,
    taxon_id,
    scientific_name,
    author_short,
    common_name,
    red_list_code,
    observation_count,
    municipality_count,
    reason_codes,
    reason_texts,
    top_priority,
    verified_count,
    obs_texts,
    first_date,
    last_date,
    has_first_in_skane,
    has_redlist,
    has_few_observations
ORDER BY
    taxon_sort_order,
    scientific_name;

-- #  v_report_lines
DROP VIEW IF EXISTS v_report_lines;
CREATE VIEW v_report_lines AS
SELECT
    d.family_name,
    d.family_name_sv,
    d.taxon_sort_order,
    d.scientific_name,
    d.author_short,
    d.common_name,
    d.red_list_code,
    d.top_priority,
    TRIM(
        d.scientific_name
        || CASE WHEN d.author_short IS NOT NULL AND d.author_short <> '' THEN ' (' || d.author_short || ')' ELSE '' END
        || CASE
            WHEN d.common_name IS NOT NULL AND d.common_name <> '' THEN ', ' || d.common_name
            ELSE ''
           END
        || CASE
            WHEN d.red_list_code IN ('CR','EN','VU','NT') THEN ', ' || d.red_list_code
            ELSE ''
           END
        || ': '
        || CASE
            WHEN d.obs_data IS NOT NULL AND d.obs_data <> '' THEN d.obs_data
            ELSE ''
           END
        || CASE
            WHEN d.closing_comment IS NOT NULL AND d.closing_comment <> '' THEN
                CASE
                    WHEN d.obs_data IS NOT NULL AND d.obs_data <> '' THEN '. ' || d.closing_comment
                    ELSE d.closing_comment
                END
            ELSE ''
           END
    ) AS report_line
FROM v_report_draft d;

-- #  v_family_headers
DROP VIEW IF EXISTS v_family_headers;
CREATE VIEW v_family_headers AS
SELECT DISTINCT
    family_name,
    family_name_sv,
    CASE
        WHEN family_name_sv IS NOT NULL AND family_name_sv <> ''
        THEN family_name || ' - ' || family_name_sv
        ELSE family_name
    END AS family_header
FROM v_report_lines
ORDER BY family_name;

-- #  v_report_output
DROP VIEW IF EXISTS v_report_output;
CREATE VIEW v_report_output AS
WITH families AS (
    SELECT DISTINCT
        rl.family_name,
        rl.family_name_sv,
        fs.family_sort_order
    FROM v_report_lines rl
    LEFT JOIN v_family_sort_order fs
        ON fs.family_name = rl.family_name
),
family_headers AS (
    SELECT
        family_name,
        family_sort_order,
        0 AS section_sort,
        0 AS line_sort,
        CASE
            WHEN family_name_sv IS NOT NULL AND family_name_sv <> ''
            THEN family_name || ' – ' || family_name_sv
            ELSE family_name
        END AS line
    FROM families
),
family_spacer AS (
    SELECT
        family_name,
        family_sort_order,
        1 AS section_sort,
        0 AS line_sort,
        ' ' AS line
    FROM families
),
species_lines AS (
    SELECT
        rl.family_name,
        fs.family_sort_order,
        2 AS section_sort,
        rl.taxon_sort_order AS line_sort,
        rl.report_line AS line
    FROM v_report_lines rl
    LEFT JOIN v_family_sort_order fs
        ON fs.family_name = rl.family_name
)
SELECT line
FROM (
    SELECT * FROM family_headers
    UNION ALL
    SELECT * FROM family_spacer
    UNION ALL
    SELECT * FROM species_lines
)
ORDER BY
    family_sort_order,
    family_name,
    section_sort,
    line_sort,
    line;

-- Find out why these are needed!!

-- #  why?
DROP VIEW IF EXISTS v_suspect_non_lep_families;
CREATE VIEW v_suspect_non_lep_families AS
SELECT *
FROM v_family_species_summary
WHERE family_name IN (
    'Anthicidae',
    'Hyaloscyphaceae',
    'Ectinosomatidae'
);


COMMIT;
