# File ./src/init_sqlite_db.py
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

DROP VIEW IF EXISTS v_species_reason_flags_2025;
CREATE VIEW v_species_reason_flags_2025 AS
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
FROM v_species_summary_2025 s
WHERE s.red_list_code IN ('CR','EN','VU','NT')

UNION ALL

SELECT
    s.taxon_id,
    s.scientific_name,
    'few_observations' AS reason_code,
    'Få observationer under året' AS reason_text,
    40 AS priority
FROM v_species_summary_2025 s
WHERE s.observation_count <= 3

UNION ALL

SELECT
    s.taxon_id,
    s.scientific_name,
    'verified' AS reason_code,
    'Minst en verifierad observation' AS reason_text,
    60 AS priority
FROM v_species_summary_2025 s
WHERE s.verified_count >= 1

UNION ALL

SELECT
    f.taxon_id,
    f.scientific_name,
    f.reason_code,
    f.reason_text,
    f.priority
FROM v_first_in_skane_2025 f;

DROP VIEW IF EXISTS v_all_species_reason_flags_2025;
CREATE VIEW v_all_species_reason_flags_2025 AS
SELECT
    taxon_id,
    scientific_name,
    reason_code,
    reason_text,
    priority
FROM v_species_reason_flags_2025

UNION ALL

SELECT
    m.taxon_id,
    m.scientific_name,
    m.reason_code,
    m.reason_text,
    m.priority
FROM species_manual_flags m;

DROP VIEW IF EXISTS v_interesting_species_2025;
CREATE VIEW v_interesting_species_2025 AS
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
FROM v_species_summary_2025 s
JOIN v_all_species_reason_flags_2025 r
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

DROP VIEW IF EXISTS v_interesting_family_species_2025;
CREATE VIEW v_interesting_family_species_2025 AS
SELECT
    COALESCE(
        t.family_name,
        fo.family_name,
        '[okänd familj]'
    ) AS family_name,
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
FROM v_interesting_species_2025 i
LEFT JOIN taxa t
    ON t.taxon_id = i.taxon_id
LEFT JOIN family_overrides fo
    ON fo.scientific_name = i.scientific_name
ORDER BY
    family_name,
    top_priority,
    i.scientific_name;

DROP VIEW IF EXISTS v_first_in_skane_2025;
CREATE VIEW v_first_in_skane_2025 AS
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
    'first_in_skane_2025' AS reason_code,
    'Första kända fyndet i Skåne infaller under 2025' AS reason_text,
    10 AS priority
FROM v_species_summary_2025 s
LEFT JOIN species_skane_history h
    ON h.taxon_id = s.taxon_id
WHERE h.first_known_year_in_skane = 2025;

CREATE TABLE IF NOT EXISTS family_names_sv (
    family_name TEXT PRIMARY KEY,
    family_name_sv TEXT NOT NULL
);
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
('Yponomeutidae', 'Spinnmalar');


DROP VIEW IF EXISTS v_observation_editorial_2025;
CREATE VIEW v_observation_editorial_2025 AS
SELECT
    o.obs_id,
    o.taxon_id,
    COALESCE(t.family_name, fo.family_name, '[okänd familj]') AS family_name,
    COALESCE(fsv.family_name_sv, '') AS family_name_sv,
    o.scientific_name,
    COALESCE(a.author_short, o.author_text) AS author_short,
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
        WHEN o.individual_count IS NULL OR TRIM(o.individual_count) = '' THEN 'noterad'
        ELSE o.individual_count || ' ex'
    END AS count_text,

    CAST(strftime('%d', substr(o.observed_at,1,19)) AS INTEGER) || '/' ||
    CAST(strftime('%m', substr(o.observed_at,1,19)) AS INTEGER) AS short_date,

    CASE
        WHEN o.reporter IS NULL OR TRIM(o.reporter) = '' THEN '[okänd rapportör]'
        WHEN instr(o.reporter, ',') > 0 THEN substr(o.reporter, 1, instr(o.reporter, ',') - 1)
        ELSE o.reporter
    END AS short_reporter,

    TRIM(
        CASE
            WHEN o.individual_count IS NULL OR TRIM(o.individual_count) = '' THEN 'noterad'
            ELSE o.individual_count || ' ex'
        END
        || ', ' ||
        (CAST(strftime('%d', substr(o.observed_at,1,19)) AS INTEGER) || '/' ||
         CAST(strftime('%m', substr(o.observed_at,1,19)) AS INTEGER))
        || ', ' ||
        CASE
            WHEN o.reporter IS NULL OR TRIM(o.reporter) = '' THEN '[okänd rapportör]'
            WHEN instr(o.reporter, ',') > 0 THEN substr(o.reporter, 1, instr(o.reporter, ',') - 1)
            ELSE o.reporter
        END
        || CASE WHEN o.locality IS NOT NULL AND TRIM(o.locality) <> '' THEN ', ' || o.locality ELSE '' END
        || CASE WHEN o.socken IS NOT NULL AND TRIM(o.socken) <> '' THEN ', ' || o.socken ELSE '' END
        || CASE
            WHEN o.source_comment IS NOT NULL
             AND TRIM(o.source_comment) <> ''
             AND length(o.source_comment) <= 120
            THEN ', ' || o.source_comment
            ELSE ''
           END
    ) AS obs_text
FROM observations o
LEFT JOIN taxa t
    ON t.taxon_id = o.taxon_id
LEFT JOIN family_overrides fo
    ON fo.scientific_name = o.scientific_name
LEFT JOIN family_names_sv fsv
    ON fsv.family_name = COALESCE(t.family_name, fo.family_name)
LEFT JOIN author_abbrev a
    ON a.author_full = o.author_text
WHERE substr(o.observed_at,1,4) = '2025'
  AND o.scientific_name NOT LIKE '%/%'
  AND COALESCE(t.taxon_rank, '') = 'species';

DROP VIEW IF EXISTS v_report_draft_2025;
CREATE VIEW v_report_draft_2025 AS
SELECT
    i.family_name,
    COALESCE(fsv.family_name_sv, '') AS family_name_sv,
    i.scientific_name,
    COALESCE(ad.author_display, i.author_text) AS author_short,
    i.common_name,
    i.red_list_code,
    i.observation_count,
    i.reason_codes,
    i.reason_texts,
    CASE
        WHEN i.observation_count <= 5 THEN GROUP_CONCAT(r.obs_text, ' ; ')
        ELSE NULL
    END AS obs_data,
    CASE
        WHEN i.observation_count > 5 THEN
            CAST(i.observation_count AS TEXT) || ' observationer i ' ||
            CAST(i.municipality_count AS TEXT) || ' kommuner. ' ||
            COALESCE(REPLACE(i.reason_texts, ',', ', '), '')
        ELSE
            COALESCE(REPLACE(i.reason_texts, ',', ', '), '')
    END AS closing_comment
FROM v_interesting_family_species_2025 i
LEFT JOIN v_ranked_observations_2025 r
    ON r.taxon_id = i.taxon_id
   AND r.rn <= 5
LEFT JOIN family_names_sv fsv
    ON fsv.family_name = i.family_name
LEFT JOIN v_author_display ad
    ON ad.taxon_id = i.taxon_id
GROUP BY
    i.family_name,
    fsv.family_name_sv,
    i.taxon_id,
    i.scientific_name,
    COALESCE(ad.author_display, i.author_text),
    i.common_name,
    i.red_list_code,
    i.observation_count,
    i.municipality_count,
    i.reason_codes,
    i.reason_texts
ORDER BY
    i.family_name,
    i.scientific_name;


DROP VIEW IF EXISTS v_report_lines_2025;
CREATE VIEW v_report_lines_2025 AS
SELECT
    family_name,
    family_name_sv,
    scientific_name,
    author_short,
    common_name,
    red_list_code,
    TRIM(
        scientific_name
        || CASE WHEN author_short IS NOT NULL AND author_short <> '' THEN ' (' || author_short || ')' ELSE '' END
        || CASE WHEN common_name IS NOT NULL AND common_name <> '' THEN ', ' || common_name ELSE '' END
        || CASE WHEN red_list_code IS NOT NULL AND red_list_code <> '' THEN ', ' || red_list_code ELSE '' END
        || ': '
        || CASE
            WHEN obs_data IS NOT NULL AND obs_data <> '' THEN obs_data
            ELSE ''
           END
        || CASE
            WHEN closing_comment IS NOT NULL AND closing_comment <> '' THEN
                CASE
                    WHEN obs_data IS NOT NULL AND obs_data <> '' THEN '. ' || closing_comment
                    ELSE closing_comment
                END
            ELSE ''
           END
    ) AS report_line
FROM v_report_draft_2025
ORDER BY family_name, scientific_name;

DROP VIEW IF EXISTS v_ranked_observations_2025;
CREATE VIEW v_ranked_observations_2025 AS
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
FROM v_observation_editorial_2025 e;

DROP VIEW IF EXISTS v_family_headers_2025;
CREATE VIEW v_family_headers_2025 AS
SELECT DISTINCT
    family_name,
    CASE
        WHEN family_name_sv IS NOT NULL AND family_name_sv <> ''
        THEN family_name || ' - ' || family_name_sv
        ELSE family_name
    END AS family_header
FROM v_report_lines_2025
ORDER BY family_name;

CREATE TABLE IF NOT EXISTS author_abbrev (
    author_full TEXT PRIMARY KEY,
    author_short TEXT NOT NULL
);


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
('Scheven', 'Sch.'),
('Ochsenheimer', 'Ochs.'),
('Duponchel', 'Dup.'),
('Clerck', 'Cl.'),
('Scopoli', 'Scop.'),
('Freyer', 'Fr.'),
('Müller', 'Müll.'),
('Röber', 'Röb.');

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

DROP VIEW IF EXISTS v_observation_editorial_dedup_2025;
CREATE VIEW v_observation_editorial_dedup_2025 AS
WITH base AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                e.taxon_id,
                e.short_date,
                COALESCE(e.short_reporter, ''),
                COALESCE(e.locality, ''),
                COALESCE(e.socken, ''),
                COALESCE(e.count_text, '')
            ORDER BY
                CASE WHEN e.source_comment IS NOT NULL AND TRIM(e.source_comment) <> '' THEN 1 ELSE 0 END DESC,
                CASE WHEN e.verified = 1 THEN 1 ELSE 0 END DESC,
                e.obs_id
        ) AS dup_rn
    FROM v_observation_editorial_2025 e
)
SELECT *
FROM base
WHERE dup_rn = 1;

DROP VIEW IF EXISTS v_ranked_observations_2025;
CREATE VIEW v_ranked_observations_2025 AS
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
FROM v_observation_editorial_dedup_2025 e;

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
