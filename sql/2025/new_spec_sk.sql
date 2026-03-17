-- file: sql/2025/new_spec_sk.sql
-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck
--
-- Searched 1900-2024, then compared with 1900-2025
-- Apply with:
--   sqlite3 ./db/obsperyear.sqlite < ./sql/2025/new_spec_sk.sql
--
-- NOTE:
--  * Only taxon_id is used for report logic
--  * note is for editor-facing readability / traceability
--  * taxa only appear in the report if they are present in the current report year

BEGIN;

INSERT OR IGNORE INTO species_skane_history
(taxon_id, first_known_year_in_skane, note)
VALUES
(6010429, 2025, 'Agrochola lunosa'),
(214165, 2025, 'Argyresthia ivella'),
(6332812, 2025, 'Caloptilia honoratella'),
(216027, 2025, 'Chloantha hyperici'),
(100636, 2025, 'Chrysoclista lathamella'),
(214458, 2025, 'Coleophora juncicolella'),
(6011700, 2025, 'Diplopseustis perieresalis'),
(6332811, 2025, 'Epiblema turbidana'),
(216289, 2025, 'Euxoa ochrogaster'),
(214233, 2025, 'Lyonetia ledi');

COMMIT;

