-- file: sql/2025/manual_insert.sql
-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck
--
-- Manual editorial reasons for inclusion in the yearly report.
-- Apply with:
--   sqlite3 ./db/obsperyear.sqlite < ./sql/manual_insert_2025.sql
--
-- Notes:
--  * Use one row per (taxon_id, reason_code)
--  * Lower priority number = stronger reason
--  * Keep reason_code short, machine-friendly, stable, examples
--     o migrant
--     o invasive
--     o range_expansion
--     o editorial_note
--     o new_for_sweden
--
--  * Keep reason_text human-readable; this may appear in report metadata
--
-- Suggested priority scale:
--   5   = exceptional (e.g. new for Sweden)
--   10  = first in Scania
--   20  = strong editorial reason
--   30  = migrant / invasive / expansion / notable occurrence
--   50  = general manual editorial inclusion
--
-- Important:
--  * Only taxa that actually occur in the current report year will appear in the report.
--  * Taxa listed here can safely remain for future years.

--

BEGIN;

INSERT OR IGNORE INTO species_manual_flags
(taxon_id, reason_code, reason_text, priority, note)
VALUES

-- Template row:
--(<taxon_id>, '<reason_code>', '<reason_text>', <priority>, '<optional note>')

-- Migrants / immigrants (ej bofasta)
(201050, 'migrant', 'Ej bofast, migrerande.', 30, 'Colias crocea'),
(100696, 'migrant', 'Bofast och migrerande.', 30, 'Colias hyale'),
(216340, 'migrant', 'Ej bofast, migrerande.', 30, 'Lampides boeticus'),

(201189, 'migrant', 'Ej bofast, migrerande.', 30, 'Agrius convolvuli'),
(201190, 'migrant', 'Ej bofast, migrerande.', 30, 'Acherontia atropos'),
(201195, 'migrant', 'Ej bofast, migrerande.', 30, 'Daphnis nerii'),
(201196, 'migrant', 'Ej bofast, migrerande.', 30, 'Macroglossum stellatarum'),
(201202, 'migrant', 'Ej bofast, migrerande.', 30, 'Hippotion celerio'),

(215508, 'migrant', 'Ej bofast, migrerande.', 30, 'Nomophila noctuella'),
(215954, 'migrant', 'Ej bofast, migrerande.', 30, 'Trichoplusia ni'),
(215997, 'migrant', 'Ej bofast, migrerande.', 30, 'Protoschinia scutosa'),
(215999, 'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis adaucta'),
(216000, 'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis peltigera'),
(216001, 'migrant', 'Ej bofast, migrerande.', 30, 'Helicoverpa armigera'),
(6324439,'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis nubigera'),
(6002710,'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis maritima'),
(101057, 'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis viriplaca'),

(216187, 'migrant', 'Ej bofast, migrerande.', 30, 'Mythimna vitellina'),
(216277, 'migrant', 'Ej bofast, migrerande.', 30, 'Peridroma saucia'),
(216013, 'migrant', 'Ej bofast, migrerande.', 30, 'Spodoptera exigua'),
(216014, 'migrant', 'Ej bofast, migrerande.', 30, 'Spodoptera littoralis'),
(216291, 'migrant', 'Ej bofast, migrerande.', 30, 'Agrotis ipsilon'),

(6010412,'migrant', 'Ej bofast, migrerande.', 30, 'Aedia leucomelas'),
(215955, 'migrant', 'Ej bofast, migrerande.', 30, 'Chrysodeixis chalcites'),

(215681, 'migrant', 'Ej bofast, migrerande.', 30, 'Rhodometra sacraria'),
(201268, 'migrant', 'Ej bofast, migrerande.', 30, 'Utetheisa pulchella'),

(215505, 'migrant', 'Ej bofast, migrerande.', 30, 'Palpita vitrealis'),
(250427, 'migrant', 'Ej bofast, migrerande.', 30, 'Herpetogramma licarsisalis'),
(6010349,'migrant', 'Ej bofast, migrerande.', 30, 'Spoladea recurvalis'),
(215460, 'migrant', 'Ej bofast, migrerande.', 30, 'Udea ferrugalis'),
(215464, 'migrant', 'Bofast och migrerande.', 30, 'Udea accolalis'),

(6010215,'migrant', 'Ej bofast, migrerande.', 30, 'Tuta absoluta'),
(216323, 'migrant', 'Ej bofast, migrerande.', 30, 'Phthorimaea operculella'),

(215377, 'migrant', 'Ej bofast, migrerande.', 30, 'Cadra cautella'),

(216328, 'migrant', 'Ej bofast, migrerande.', 30, 'Grapholita molesta'),
(6003438,'migrant', 'Ej bofast, migrerande.', 30, 'Epiphyas postvittana'), 
(215912, 'migrant', 'Ej bofast, migrerande.', 30, 'Catocala electa, Stenfärgat ordensfly'),

(101366, 'migrant', 'Bofast och migrerande.', 30, 'Mythimna turca'),
(215397, 'migrant', 'Ej bofast, migrerande.', 30, 'Euchromius ocellea, vandrargräsmott'),


(215976, 'migrant', 'Ej bofast, migrerande.', 25, 'Cucullia boryphora, stäppkapuchongfly'),
(215991, 'migrant', 'Ej bofast, migrerande.', 25, 'Amphipyra livida, svart buskfly'),

-- Expanding / invasive / otherwise notable
(216027, 'range_expansion', 'Möjlig expansion i landskapet', 30, 'Chloantha hyperici'),
(100328, 'editorial_note', 'Möjlig expansion i landskapet.', 25, 'Apatura iris'),
(100564, 'editorial_note', 'Särskilt intressant fynd.', 25, 'Catocala pacta'),
(6010418,'editorial_note', 'Särskilt intressant fynd.', 15, 'Mormo maura, Svartbandat ordensfly'),
(6331497,'editorial_note', 'Särskilt intressant fynd.', 15, 'Catephia alchymista, vitt ordensfly'),
(6010429,'editorial_note', 'Särskilt intressant fynd.', 5, 'Agrochola lunosa, månfläckat backfly'),

(6008270, 'invasive', 'Invasiv art att bevaka.', 30, 'Lindguldmal'),
(6010351, 'invasive', 'Invasiv art att bevaka.', 30, 'Buxbomsmott'),

(216335, 'editorial_note', 'Införd art.', 25, 'Cadra figulilella'),
(216336, 'editorial_note', 'Införd art.', 25, 'Cadra calidella'),
(216337, 'editorial_note', 'Införd art.', 25, 'Parapoynx bilinealis Rödbrämat akvariemott'),


(6010337,'editorial_note', 'Nyetablerad art.', 25, 'Ephestia woodiella'),
(6329888,'editorial_note', 'Nyetablerad art.', 25, 'Cnephasia pumicana'),
(233225, 'editorial_note', 'Nyetablerad art.', 25, 'Nemophora ochsenheimerella, fläckantennmal'),
(6332409,'editorial_note', 'Nyetablerad art.', 25, 'Antispila treitschkiella, körsbärskornellmal'),
(6008312,'editorial_note', 'Nyetablerad art.', 25, 'Phyllonorycter comparellus, gråpoppelguldmal'), 
(6008310,'editorial_note', 'Nyetablerad art.', 25, 'Phyllonorycter mespilella, tyskoxelguldmal'), 
(6331775,'editorial_note', 'Nyetablerad art.', 25, 'Luffia lapidella, hornsäckspinnare'),
(6332812,'editorial_note', 'Nyetablerad art.', 25, 'Caloptilia honoratella, dvärglönnstyltmal, ny 2025'),
(263745, 'editorial_note', 'Nyetablerad art.', 25, 'Caloptilia fidella, humlestyltmal'),
(6010292,'editorial_note', 'Nyetablerad art.', 25, 'Lozotaeniodes formosana, skäckig tallvecklare'),
(6010237,'editorial_note', 'Nyetablerad art.', 25, 'Coleophora coronillae, kronillsäckmal'),
(6007442,'editorial_note', 'Nyetablerad art.', 25, 'Stigmella minusculella, bronsdvärgmal'),
(215390, 'editorial_note', 'Nyetablerad art.', 25, 'Eudonia delunella, kvadratugglemott'),
(6010305,'editorial_note', 'Nyetablerad art.', 25, 'Crocidosema plebejana, kattostfrövecklare'),
(100372, 'editorial_note', 'Nyetablerad art.', 25, 'Apterona helicoidella, snäcksäckspinnare');

-- Exceptional cases
--(214165, 'new_for_sweden', 'Ny art för Sverige', 5, 'Aktiveras endast om relevant');



COMMIT;
