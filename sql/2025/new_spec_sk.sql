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

-- New for Sweden (and Skåne and artportalen) 2025
(6010380, 2025, 'Stegania trimaculata'), 
(6008327, 2025, 'Phyllonorycter medicaginellus'), 
(6010380, 2025, 'Agrochola lunosa'), 
(6332811, 2025, 'Epiblema turbidana'),
(6332812, 2025, 'Caloptilia honoratella'),

-- New Skåne provincal find 2025 (and first artportalen)
(216027, 2025, 'Chloantha hyperici'),
(6011700, 2025, 'Diplopseustis perieresalis'),
(216289, 2025, 'Euxoa ochrogaster'),
(6010215, 2025, 'Tuta absoluta'), 
(102500, 2025, 'Scrobipalpa salicorniae'),
(216322, 2025, 'Zelleria oleastrella'),
(6010429, 2025,'Agrochola lunosa');

COMMIT;

