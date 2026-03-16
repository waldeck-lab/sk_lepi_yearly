-- file: ./sql/schema.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

-- Viktigt:
-- observations.taxon_id från SOS matchar inte säkert taxa.taxon_id från Dyntaxa DWCA.
-- För rapportvyer joinar vi därför taxa på scientific_name. Kan behöva fixas till bättre senare!

PRAGMA foreign_keys = ON;
BEGIN; 
-- =========================================================
-- TABLES
-- =========================================================

CREATE TABLE IF NOT EXISTS observations (
    obs_id TEXT PRIMARY KEY,
    taxon_id INTEGER,
    taxon_sort_order INTEGER,
    lep_group_sort INTEGER,
    lep_group_code TEXT,
    lep_group_label TEXT,
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

-- Use for temporary insertions of new columns

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
('Adelidae', 'Antennmalar'),
('Alucitidae', 'Mångfliksmott'),
('Argyresthiidae', 'Hängemalar'),
('Bucculatricidae', 'Kronmalar'),
('Choreutidae', 'Gnidmalar'),
('Coleophoridae', 'Säckmalar'),
('Crambidae', 'Mott'),
('Depressariidae', 'Plattmalar'),
('Douglasiidae', 'Skäckmalar'),
('Epermeniidae', 'Skärmmalar'),
('Erebidae', 'Björkspinnare & lappmätare'),
('Eriocraniidae', 'Purpurmalar'),
('Geometridae', 'Mätare'),
('Glyphipterigidae', 'Hakmalar'),
('Gracillariidae', 'Styltmalar & guldmalar'),
('Heliozelidae', 'Hålmalar'),
('Incurvariidae', 'Bladskärare'),
('Limacodidae', 'Snigelspinnare'),
('Lycaenidae', 'Blåvingar'),
('Lyonetiidae', 'Lansettmalar'),
('Lypusidae', 'Tubmalar'),
('Momphidae', 'Dunörtsmalar'),
('Nepticulidae', 'Dvärgmalar'),
('Noctuidae', 'Nattflyn'),
('Nymphalidae', 'Praktfjärilar'),
('Parametriotidae', 'Brokmalar'),
('Pieridae', 'Vitfjärilar'),
('Plutellidae', 'Korsblommalar'),
('Prodoxidae', 'Knoppmalar'),
('Psychidae', 'Säckspinnare'),
('Scythrididae', 'Fältmalar'),
('Sphingidae', 'Svärmare'),
('Tortricidae', 'Vecklare'),
('Yponomeutidae', 'Spinnmalar'),
('Ypsolophidae', 'Tandmalar'),
('Zygaenidae', 'Bastardsvärmare'),
('Autostichidae', 'Praktmalar'),
('Batrachedridae', 'Smalkroppsmalar'),
('Blastobasidae', 'Fruktmalar'),
('Chimabachidae', 'Skogsmalar'),
('Cosmopterigidae', 'Praktmalar'),
('Cossidae', 'Träfjärilar'),
('Drepanidae', 'Sikelvingar'),
('Elachistidae', 'Gräsminerarmalar'),
('Endromidae', 'Björkspinnare'),
('Gelechiidae', 'Palpmalar'),
('Hepialidae', 'Rotfjärilar'),
('Hesperiidae', 'Tjockhuvuden'),
('Lasiocampidae', 'Ringelspinnare'),
('Micropterigidae', 'Urmalar'),
('Nolidae', 'Pudermott'),
('Notodontidae', 'Tandspinnare'),
('Oecophoridae', 'Vedmalar'),
('Opostegidae', 'Sköldmalar'),
('Papilionidae', 'Riddarfjärilar'),
('Peleopodidae', 'Prydmalar'),
('Praydidae', 'Olivmalar'),
('Pterophoridae', 'Fjädermott'),
('Pyralidae', 'Pyralismott'),
('Roeslerstammiidae', 'Metallmalar'),
('Saturniidae', 'Påfågelspinnare'),
('Schreckensteiniidae', 'Nässelmalar'),
('Scythropiidae', 'Skräpmalar'),
('Sesiidae', 'Glasvingar'),
('Stathmopodidae', 'Praktmalar'),
('Tineidae', 'Klädesmalar'),
('Tischeriidae', 'Trädminerarmalar');

INSERT OR IGNORE INTO author_abbrev (author_full, author_short) VALUES
('Linnaeus', 'L.'),
('Linnaé', 'L.'),
('Fabricius', 'F.'),
('Haworth', 'Haw.'),
('Herrich-Schäffer', 'H-S'),
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
('Röber', 'Röb.'),
('Allen', 'All.'),
('Amsel', 'Ams.'),
('Barrett', 'Barr.'),
('Barret', 'Barr.'),
('Bastelberger', 'Bast.'),
('Benander', 'Ben.'),
('Bengtsson', 'Bengt.'),
('Berggren', 'Berggr.'),
('Billberg', 'Billb.'),
('Bjerkander', 'Bjerk.'),
('Boisduval', 'Boisd.'),
('Borkhausen', 'Bkh.'),
('Bosc', 'Bosc'),
('Bouché', 'Bouch.'),
('Boursin', 'Bours.'),
('Brahm', 'Brahm'),
('Bremer', 'Brem.'),
('Bruand', 'Bru.'),
('Butler', 'Butl.'),
('Christoph', 'Chr.'),
('Clemens', 'Clem.'),
('Curtis', 'Curt.'),
('Dale', 'Dale'),
('Dalman', 'Dalm.'),
('De Geer', 'DeGeer'),
('De Lattin', 'Latt.'),
('Deschka & Dimić', 'Deschka & Dim.'),
('Djakonov', 'Djak.'),
('Doets', 'Doets'),
('Donovan', 'Don.'),
('Donzel', 'Donz.'),
('Doubleday', 'Dbl.'),
('Douglas', 'Dougl.'),
('Durrant', 'Durr.'),
('E.Hering', 'Her.'),
('Elisha', 'Elisha'),
('Eversmann', 'Eversm.'),
('Falck', 'Falck'),
('Fenn', 'Fenn'),
('Fletcher', 'Fletch.'),
('Fologne', 'Folog.'),
('Forster', 'Forst.'),
('Fourcroy', 'Fourcr.'),
('Frey', 'Frey'),
('Frölich', 'Fröl.'),
('Fuchs', 'Fuchs'),
('Fuessly', 'Fuessl.'),
('Geoffroy', 'Geoff.'),
('Gerasimov', 'Geras.'),
('Germar', 'Germ.'),
('Geyer', 'Gey.'),
('Glitz', 'Glitz'),
('Goeze', 'Goeze'),
('Gozmany', 'Gozm.'),
('Gregersen & Karsholt', 'G&K'),
('Gregor & Povolný', 'G&P'),
('Grote', 'Grote'),
('Guenée', 'Guen.'),
('Hampson', 'Hamps.'),
('Fischer von Röslerstamm', 'F.v.R.'),
('F. v Röslerstam', 'F.v.R.'),
('F.v Röslerstam', 'F.v.R.'),
('Heinemann','Hein.'),
('Hufnagel','Huf.'),
('Lienig & Zeller','L&Z'),
('Metcalfe','Met.'),
('Oberthür','Ober.'),
('Schläger','Schl.'),
('Sodoffsky','Sod.'),
('Thunberg','Thun.'),
('Walsingham','Wals.'),
('de Villers','Vill.'),
('von Heyden','Heyd.');

-- =========================================================
-- App parameter (year) 
-- =========================================================
CREATE TABLE IF NOT EXISTS app_config (
    config_key TEXT PRIMARY KEY,
    config_value TEXT NOT NULL
);

-- Parameter: Reporting year (format: 4 digit INT)
INSERT OR IGNORE INTO app_config (config_key, config_value)
VALUES ('report_year', '2025');

-- Parameter: Formatted output (format: BOOL)
INSERT OR IGNORE INTO app_config (config_key, config_value)
VALUES ('report_formatted', 'false');

-- Parameter: Verbose output (format: BOOL)
INSERT OR IGNORE INTO app_config (config_key, config_value)
VALUES ('verbose_output', 'false');

-- Parameter: Few observations threshold (0 = disabled)
INSERT OR IGNORE INTO app_config (config_key, config_value)
VALUES ('few_observations_threshold', '3');

-- Parameter: Merge family headers by shared Swedish alias (format: BOOL)
INSERT OR IGNORE INTO app_config (config_key, config_value)
VALUES ('merge_family_headers_by_sv_alias', 'true');

-- #  v_report_year
DROP VIEW IF EXISTS v_report_year;
CREATE VIEW v_report_year AS
SELECT CAST(config_value AS INTEGER) AS report_year
FROM app_config
WHERE config_key = 'report_year';

-- #  v_report_format
DROP VIEW IF EXISTS v_report_format;
CREATE VIEW v_report_format AS
SELECT
    CASE
        WHEN LOWER(TRIM(config_value)) IN ('1', 'true', 'yes', 'on')
        THEN 1
        ELSE 0
    END AS report_formatted
FROM app_config
WHERE config_key = 'report_formatted';

-- #  v_verbose_output
DROP VIEW IF EXISTS v_verbose_output;
CREATE VIEW v_verbose_output AS
SELECT
    CASE
        WHEN LOWER(TRIM(config_value)) IN ('1', 'true', 'yes', 'on')
        THEN 1
        ELSE 0
    END AS verbose_output
FROM app_config
WHERE config_key = 'verbose_output';


-- # v_few_obs_threshold
DROP VIEW IF EXISTS v_few_obs_threshold;
CREATE VIEW v_few_obs_threshold AS
SELECT
    CAST(config_value AS INTEGER) AS few_obs_threshold
FROM app_config
WHERE config_key = 'few_observations_threshold';

-- #  v_merge_family_headers
DROP VIEW IF EXISTS v_merge_family_headers;
CREATE VIEW v_merge_family_headers AS
SELECT
    CASE
        WHEN LOWER(TRIM(config_value)) IN ('1', 'true', 'yes', 'on')
        THEN 1
        ELSE 0
    END AS merge_family_headers
FROM app_config
WHERE config_key = 'merge_family_headers_by_sv_alias';


-- # v_config_status
DROP VIEW IF EXISTS v_config_status;

CREATE VIEW v_config_status AS
SELECT
    MAX(CASE
        WHEN config_key = 'report_year' THEN config_value
    END) AS report_year,

    CASE
        WHEN LOWER(TRIM(MAX(CASE
            WHEN config_key = 'report_formatted' THEN config_value
        END))) IN ('1','true','yes','on')
        THEN 'ON'
        ELSE 'OFF'
    END AS formatted_output,

    CASE
        WHEN LOWER(TRIM(MAX(CASE
            WHEN config_key = 'verbose_output' THEN config_value
        END))) IN ('1','true','yes','on')
        THEN 'ON'
        ELSE 'OFF'
    END AS verbose_output,

    MAX(CASE
        WHEN config_key = 'few_observations_threshold'
        THEN config_value
    END) AS few_obs_threshold,

    CASE
        WHEN LOWER(TRIM(MAX(CASE
            WHEN config_key = 'merge_family_headers_by_sv_alias' THEN config_value
        END))) IN ('1','true','yes','on')
        THEN 'ON'
        ELSE 'OFF'
    END AS merge_family_headers

FROM app_config;



-- =========================================================
-- Config table
-- =========================================================
CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- Lepidoptera chapter grouping (Macro / Micro)
-- =========================================================

-- taxon 6039937 = Storfjärilar / Lepidoptera, macro
-- taxon 6039938 = Småfjärilar / Lepidoptera, micro

DROP VIEW IF EXISTS v_lep_group_map;
CREATE VIEW v_lep_group_map AS
WITH RECURSIVE lineage AS (
    SELECT
        t.taxon_id AS start_taxon_id,
        t.taxon_id AS ancestor_taxon_id,
        t.parent_taxon_id,
        0 AS depth
    FROM taxa t

    UNION ALL

    SELECT
        l.start_taxon_id,
        p.taxon_id AS ancestor_taxon_id,
        p.parent_taxon_id,
        l.depth + 1
    FROM lineage l
    JOIN taxa p
        ON p.taxon_id = l.parent_taxon_id
    WHERE l.parent_taxon_id IS NOT NULL
      AND l.depth < 100
),
grouped AS (
    SELECT
        start_taxon_id AS taxon_id,
        MAX(CASE WHEN ancestor_taxon_id = 6039937 THEN 1 ELSE 0 END) AS is_macro,
        MAX(CASE WHEN ancestor_taxon_id = 6039938 THEN 1 ELSE 0 END) AS is_micro
    FROM lineage
    GROUP BY start_taxon_id
)
SELECT
    taxon_id,
    CASE
        WHEN is_macro = 1 THEN 1
        WHEN is_micro = 1 THEN 2
        ELSE 99
    END AS lep_group_sort,
    CASE
        WHEN is_macro = 1 THEN 'macro'
        WHEN is_micro = 1 THEN 'micro'
        ELSE 'other'
    END AS lep_group_code,
    CASE
        WHEN is_macro = 1 THEN 'Macro Lepidoptera - Storfjärilar'
        WHEN is_micro = 1 THEN 'Micro Lepidoptera - Småfjärilar'
        ELSE 'Övrigt'
    END AS lep_group_label
FROM grouped;


-- =========================================================
-- Lepidopera taxa filter
-- =========================================================

DROP VIEW IF EXISTS v_taxa_lepidoptera;
CREATE VIEW v_taxa_lepidoptera AS
WITH ranked AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY t.scientific_name
            ORDER BY
                CASE WHEN COALESCE(t.family_name, '') <> '' THEN 0 ELSE 1 END,
                CASE WHEN COALESCE(t.taxon_rank, '') = 'species' THEN 0 ELSE 1 END,
                CASE WHEN COALESCE(t.taxonomic_status, '') = 'accepted' THEN 0 ELSE 1 END,
                t.taxon_id
        ) AS rn
    FROM taxa t
    WHERE t.order_name = 'Lepidoptera'
      AND COALESCE(t.scientific_name, '') <> ''
)
SELECT *
FROM ranked
WHERE rn = 1;

-- =========================================================
-- Author abbreviation report view 
-- Only authors used in current report output
-- =========================================================

DROP VIEW IF EXISTS v_author_abbrev_report;

CREATE VIEW v_author_abbrev_report AS
WITH report_authors AS (
    SELECT DISTINCT
        d.scientific_name
    FROM v_report_draft d
),
author_rows AS (
    SELECT DISTINCT
        ad.author_display AS abbrev,
        ad.author_normalized AS author_full
    FROM v_author_display ad
    JOIN report_authors r
        ON r.scientific_name = ad.scientific_name
    WHERE COALESCE(TRIM(ad.author_display), '') <> ''
      AND COALESCE(TRIM(ad.author_normalized), '') <> ''
),
author_rows_sorted AS (
    SELECT
        abbrev,
        author_full
    FROM author_rows
    ORDER BY abbrev, author_full
)
SELECT
    abbrev,
    REPLACE(GROUP_CONCAT(author_full), ',', ' / ') AS author_full_names
FROM author_rows_sorted
GROUP BY abbrev
ORDER BY abbrev;

-- =========================================================
-- Sorting views
-- =========================================================

-- #  v_family_sort_order
DROP VIEW IF EXISTS v_family_sort_order;
CREATE VIEW v_family_sort_order AS
SELECT
    lep_group_sort,
    lep_group_code,
    lep_group_label,
    family_name,
    MIN(taxon_sort_order) AS family_sort_order
FROM v_interesting_family_species
GROUP BY
    lep_group_sort,
    lep_group_code,
    lep_group_label,
    family_name;

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
LEFT JOIN v_taxa_lepidoptera t
    ON t.scientific_name = o.scientific_name
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
LEFT JOIN v_taxa_lepidoptera t
    ON t.scientific_name = o.scientific_name
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
LEFT JOIN v_taxa_lepidoptera t
    ON t.scientific_name = s.scientific_name
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
    'Första Artportalen notering för Skåne.' AS reason_text,
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
WHERE
    (SELECT COALESCE(MAX(few_obs_threshold), 0) FROM v_few_obs_threshold) > 0
    AND COALESCE(s.red_list_code, '') NOT IN ('CR','EN','VU','NT')
    AND s.observation_count <= (
        SELECT COALESCE(MAX(few_obs_threshold), 0)
        FROM v_few_obs_threshold
    )

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
    COALESCE(MIN(o.lep_group_sort), 99) AS lep_group_sort,
    COALESCE(MIN(o.lep_group_code), 'other') AS lep_group_code,
    COALESCE(MIN(o.lep_group_label), 'Övrigt') AS lep_group_label,
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
LEFT JOIN v_taxa_lepidoptera t 
    ON t.scientific_name = i.scientific_name
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
    LEFT JOIN v_taxa_lepidoptera t
    	 ON t.scientific_name = o.scientific_name
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
        i.lep_group_sort,
        i.lep_group_code,
        i.lep_group_label,
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
        (SELECT COALESCE(MAX(verbose_output), 0) FROM v_verbose_output) AS verbose_output,

        CASE
            WHEN instr(COALESCE(i.reason_codes, ''), 'first_in_skane') > 0 THEN 1
            ELSE 0
        END AS has_first_in_skane,

        CASE
            WHEN i.red_list_code IN ('CR', 'EN', 'VU', 'NT') THEN 1
            ELSE 0
        END AS has_redlist,

	CASE
		WHEN
	   	    (
			SELECT few_obs_threshold
            		FROM v_few_obs_threshold
           	    ) > 0
           	    AND i.red_list_code NOT IN ('CR','EN','VU','NT')
           	    AND i.observation_count <= (
               	    	SELECT few_obs_threshold
               		FROM v_few_obs_threshold
          	    )
    	  	THEN 1
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
    lep_group_sort,
    lep_group_code,
    lep_group_label,
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
                WHEN has_first_in_skane = 1 OR (has_redlist = 1 AND verbose_output = 1) THEN
                    '. ' ||
                    TRIM(
                        CASE
                            WHEN has_first_in_skane = 1
                            THEN 'Första kända fyndet i Skåne infaller under valt rapportår'
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_first_in_skane = 1 AND has_redlist = 1 AND verbose_output = 1
                            THEN '. '
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_redlist = 1 AND verbose_output = 1
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
                        WHEN has_first_in_skane = 1 AND has_redlist = 1 AND verbose_output = 1
                        THEN '. '
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_redlist = 1 AND verbose_output = 1
                        THEN 'Rödlistad art'
                        ELSE ''
                    END ||
                    CASE
                        WHEN (
                            has_first_in_skane = 1
                            OR (has_redlist = 1 AND verbose_output = 1)
                        )
                        AND has_few_observations = 1
                        AND verbose_output = 1
                        THEN '. '
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_few_observations = 1 AND verbose_output = 1
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
                WHEN has_first_in_skane = 1 OR (has_redlist = 1 AND verbose_output = 1) THEN
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
                            WHEN has_first_in_skane = 1 AND has_redlist = 1 AND verbose_output = 1
                            THEN '. '
                            ELSE ''
                        END ||
                        CASE
                            WHEN has_redlist = 1 AND verbose_output = 1
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
                        WHEN has_first_in_skane = 1 AND has_redlist = 1 AND verbose_output = 1
                        THEN '. '
                        ELSE ''
                    END ||
                    CASE
                        WHEN has_redlist = 1 AND verbose_output = 1
                        THEN 'Rödlistad art'
                        ELSE ''
                    END
                ),
                ''
            )
    END AS closing_comment

FROM base
GROUP BY
    lep_group_sort,
    lep_group_code,
    lep_group_label,
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
    verbose_output,
    has_first_in_skane,
    has_redlist,
    has_few_observations
ORDER BY
    lep_group_sort,
    taxon_sort_order,
    scientific_name;


-- #  v_report_lines
DROP VIEW IF EXISTS v_report_lines;
CREATE VIEW v_report_lines AS
WITH fmt AS (
    SELECT COALESCE(MAX(report_formatted), 0) AS report_formatted
    FROM v_report_format
)
SELECT
    d.lep_group_sort,
    d.lep_group_code,
    d.lep_group_label,
    d.family_name,
    d.family_name_sv,
    d.taxon_sort_order,
    d.scientific_name,
    d.author_short,
    d.common_name,
    d.red_list_code,
    d.top_priority,
    TRIM(
        CASE
            WHEN (SELECT report_formatted FROM fmt) = 1
            THEN '*' || d.scientific_name || '*'
            ELSE d.scientific_name
        END
        || CASE
            WHEN d.author_short IS NOT NULL AND d.author_short <> ''
            THEN ' (' || d.author_short || ')'
            ELSE ''
        END
        || CASE
            WHEN d.common_name IS NOT NULL AND d.common_name <> ''
            THEN ', ' || d.common_name
            ELSE ''
        END
        || CASE
            WHEN d.red_list_code IN ('CR','EN','VU','NT','DD','RE')
            THEN ', ' ||
                 CASE
                     WHEN (SELECT report_formatted FROM fmt) = 1
                     THEN '**' || d.red_list_code || '**'
                     ELSE d.red_list_code
                 END
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
WITH merge_cfg AS (
    SELECT COALESCE(MAX(merge_family_headers), 0) AS merge_family_headers
    FROM v_merge_family_headers
),
families AS (
    SELECT DISTINCT
        rl.lep_group_sort,
        rl.lep_group_code,
        rl.lep_group_label,
        rl.family_name,
        rl.family_name_sv,
        fs.family_sort_order
    FROM v_report_lines rl
    LEFT JOIN v_family_sort_order fs
        ON fs.lep_group_sort = rl.lep_group_sort
       AND fs.family_name = rl.family_name
),
family_header_map AS (
    SELECT
        f.lep_group_sort,
        f.lep_group_code,
        f.lep_group_label,
        f.family_name,
        f.family_name_sv,
        f.family_sort_order,
        CASE
            WHEN (SELECT merge_family_headers FROM merge_cfg) = 1
                 AND COALESCE(TRIM(f.family_name_sv), '') <> ''
            THEN f.family_name_sv
            ELSE '__NO_MERGE__:' || f.family_name
        END AS header_group_key
    FROM families f
),
header_groups AS (
    SELECT
        lep_group_sort,
        lep_group_code,
        lep_group_label,
        header_group_key,
        MAX(COALESCE(family_name_sv, '')) AS family_name_sv,
        MIN(family_sort_order) AS header_sort_order
    FROM family_header_map
    GROUP BY
        lep_group_sort,
        lep_group_code,
        lep_group_label,
        header_group_key
)
SELECT
    hg.lep_group_sort,
    hg.lep_group_code,
    hg.lep_group_label,
    hg.header_group_key,
    hg.header_sort_order,
    CASE
        WHEN (SELECT merge_family_headers FROM merge_cfg) = 1
             AND COALESCE(TRIM(hg.family_name_sv), '') <> ''
        THEN
            (
                SELECT GROUP_CONCAT(x.family_name, ', ')
                FROM (
                    SELECT f2.family_name
                    FROM family_header_map f2
                    WHERE f2.lep_group_sort = hg.lep_group_sort
                      AND f2.header_group_key = hg.header_group_key
                    ORDER BY f2.family_sort_order, f2.family_name
                ) x
            ) || ' - ' || hg.family_name_sv
        ELSE
            REPLACE(hg.header_group_key, '__NO_MERGE__:', '')
    END AS family_header
FROM header_groups hg
ORDER BY
    hg.lep_group_sort,
    hg.header_sort_order,
    hg.header_group_key;

-- #  v_report_output
DROP VIEW IF EXISTS v_report_output;
CREATE VIEW v_report_output AS
WITH merge_cfg AS (
    SELECT COALESCE(MAX(merge_family_headers), 0) AS merge_family_headers
    FROM v_merge_family_headers
),
families AS (
    SELECT DISTINCT
        rl.lep_group_sort,
        rl.lep_group_code,
        rl.lep_group_label,
        rl.family_name,
        rl.family_name_sv,
        fs.family_sort_order
    FROM v_report_lines rl
    LEFT JOIN v_family_sort_order fs
        ON fs.lep_group_sort = rl.lep_group_sort
       AND fs.family_name = rl.family_name
),
family_header_map AS (
    SELECT
        f.lep_group_sort,
        f.lep_group_code,
        f.lep_group_label,
        f.family_name,
        f.family_name_sv,
        f.family_sort_order,
        CASE
            WHEN (SELECT merge_family_headers FROM merge_cfg) = 1
                 AND COALESCE(TRIM(f.family_name_sv), '') <> ''
            THEN f.family_name_sv
            ELSE '__NO_MERGE__:' || f.family_name
        END AS header_group_key
    FROM families f
),
header_groups AS (
    SELECT
        lep_group_sort,
        lep_group_code,
        lep_group_label,
        header_group_key,
        MAX(COALESCE(family_name_sv, '')) AS family_name_sv,
        MIN(family_sort_order) AS header_sort_order
    FROM family_header_map
    GROUP BY
        lep_group_sort,
        lep_group_code,
        lep_group_label,
        header_group_key
),
chapters AS (
    SELECT DISTINCT
        lep_group_sort,
        lep_group_code,
        lep_group_label
    FROM families
    WHERE lep_group_sort IN (1, 2)
),
chapter_headers AS (
    SELECT
        lep_group_sort,
        '' AS family_name,
        '' AS header_group_key,
        -20 AS header_sort_order,
        0 AS section_sort,
        0 AS line_sort,
        lep_group_label AS line
    FROM chapters
),
chapter_spacer AS (
    SELECT
        lep_group_sort,
        '' AS family_name,
        '' AS header_group_key,
        -19 AS header_sort_order,
        1 AS section_sort,
        0 AS line_sort,
        ' ' AS line
    FROM chapters
),
family_headers AS (
    SELECT
        hg.lep_group_sort,
        '' AS family_name,
        hg.header_group_key,
        hg.header_sort_order,
        10 AS section_sort,
        0 AS line_sort,
        CASE
            WHEN (SELECT merge_family_headers FROM merge_cfg) = 1
                 AND COALESCE(TRIM(hg.family_name_sv), '') <> ''
            THEN
                (
                    SELECT GROUP_CONCAT(x.family_name, ', ')
                    FROM (
                        SELECT f2.family_name
                        FROM family_header_map f2
                        WHERE f2.lep_group_sort = hg.lep_group_sort
                          AND f2.header_group_key = hg.header_group_key
                        ORDER BY f2.family_sort_order, f2.family_name
                    ) x
                ) || ' - ' || hg.family_name_sv
            ELSE
                REPLACE(hg.header_group_key, '__NO_MERGE__:', '')
        END AS line
    FROM header_groups hg
),
family_spacer_before AS (
    SELECT
        hg.lep_group_sort,
        '' AS family_name,
        hg.header_group_key,
        hg.header_sort_order,
        11 AS section_sort,
        0 AS line_sort,
        ' ' AS line
    FROM header_groups hg
),
species_lines AS (
    SELECT
        rl.lep_group_sort,
        rl.family_name,
        fm.header_group_key,
        hg.header_sort_order,
        12 AS section_sort,
        rl.taxon_sort_order AS line_sort,
        rl.report_line AS line
    FROM v_report_lines rl
    JOIN family_header_map fm
        ON fm.lep_group_sort = rl.lep_group_sort
       AND fm.family_name = rl.family_name
    JOIN header_groups hg
        ON hg.lep_group_sort = fm.lep_group_sort
       AND hg.header_group_key = fm.header_group_key
),
family_spacer_after AS (
    SELECT
        hg.lep_group_sort,
        '' AS family_name,
        hg.header_group_key,
        hg.header_sort_order,
        13 AS section_sort,
        0 AS line_sort,
        ' ' AS line
    FROM header_groups hg
)
SELECT line
FROM (
    SELECT * FROM chapter_headers
    UNION ALL
    SELECT * FROM chapter_spacer
    UNION ALL
    SELECT * FROM family_headers
    UNION ALL
    SELECT * FROM family_spacer_before
    UNION ALL
    SELECT * FROM species_lines
    UNION ALL
    SELECT * FROM family_spacer_after
)
ORDER BY
    lep_group_sort,
    header_sort_order,
    header_group_key,
    section_sort,
    line_sort,
    line;

-- end of views & tables

COMMIT;
