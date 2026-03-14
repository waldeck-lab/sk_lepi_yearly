-- file: ../sql/new_spec_sk_2025.sql
-- Searched 1900-2024, then compared with 1900-2025
-- add with sqlite3 obsperyear.sqlite < new_spec_sk_2025.sql
INSERT OR IGNORE INTO species_skane_history
(taxon_id, scientific_name, first_known_year_in_skane)
VALUES
(6010429, 'Agrochola lunosa', 2025),
(214165, 'Argyresthia ivella', 2025),
(6332812, 'Caloptilia honoratella', 2025),
(216027, 'Chloantha hyperici', 2025),
(100636, 'Chrysoclista lathamella', 2025),
(214458, 'Coleophora juncicolella', 2025),
(6011700, 'Diplopseustis perieresalis', 2025),
(6332811, 'Epiblema turbidana', 2025),
(216289, 'Euxoa ochrogaster', 2025),
(214233, 'Lyonetia ledi', 2025);
