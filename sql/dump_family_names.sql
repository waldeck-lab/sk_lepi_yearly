-- file: sql/dump_family_names.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

.headers on
.mode tabs

BEGIN;

SELECT
    f.family_name,
    COALESCE(fsv.family_name_sv, '') AS family_name_sv,
    CASE
        WHEN fsv.family_name_sv IS NULL OR TRIM(fsv.family_name_sv) = '' THEN 'MISSING'
        ELSE ''
    END AS needs_sv_alias,
    f.n_taxa_used,
    f.n_observations_used
FROM (
    SELECT
        COALESCE(t.family_name, fo.family_name, '[okänd familj]') AS family_name,
        COUNT(DISTINCT o.scientific_name) AS n_taxa_used,
        COUNT(*) AS n_observations_used
    FROM observations o
    LEFT JOIN v_taxa_lepidoptera t
        ON t.scientific_name = o.scientific_name
    LEFT JOIN family_overrides fo
        ON fo.scientific_name = o.scientific_name
    WHERE
        o.scientific_name NOT LIKE '%/%'
        AND COALESCE(t.taxon_rank, '') = 'species'
        AND COALESCE(t.family_name, fo.family_name, '') <> ''
    GROUP BY
        COALESCE(t.family_name, fo.family_name, '[okänd familj]')
) f
LEFT JOIN family_names_sv fsv
    ON fsv.family_name = f.family_name
ORDER BY
    f.family_name;

COMMIT; 
