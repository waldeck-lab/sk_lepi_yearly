-- file: sql/dump_authors.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

.headers on
.mode tabs

BEGIN;

WITH author_base AS (
    SELECT DISTINCT
        t.taxon_id,
        t.scientific_name,
        COALESCE(t.author_text, '') AS author_raw
    FROM taxa t
    JOIN observations o
        ON o.taxon_id = t.taxon_id
    WHERE COALESCE(TRIM(t.author_text), '') <> ''
),
author_clean AS (
    SELECT
        taxon_id,
        scientific_name,
        author_raw,
        TRIM(
            REPLACE(
                REPLACE(author_raw, '(', ''),
                ')', ''
            )
        ) AS author_no_paren
    FROM author_base
),
author_norm AS (
    SELECT
        taxon_id,
        scientific_name,
        author_raw,
        TRIM(
            CASE
                WHEN instr(author_no_paren, ',') > 0
                THEN substr(author_no_paren, 1, instr(author_no_paren, ',') - 1)
                ELSE author_no_paren
            END
        ) AS author_normalized
    FROM author_clean
)
SELECT
    n.author_normalized,
    COALESCE(a.author_short, '') AS author_short,
    n.author_raw,
    n.taxon_id,
    n.scientific_name
FROM author_norm n
LEFT JOIN author_abbrev a
    ON a.author_full = n.author_normalized
ORDER BY
    n.author_normalized,
    n.scientific_name,
    n.taxon_id;

COMMIT; 
