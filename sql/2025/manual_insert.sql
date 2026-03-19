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
(216001, 'migrant', 'Ej bofast, migrerande.', 30, 'Helicovex1rpa armigera'),
(6324439,'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis nubigera'),
(6002710,'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis maritima'),
(101057, 'migrant', 'Ej bofast, migrerande.', 30, 'Heliothis viriplaca'),

(216187, 'migrant', 'Ej bofast, migrerande.', 30, 'Mythimna vitellina'),
(216277, 'migrant', 'Ej bofast, migrerande.', 30, 'Peridroma saucia'),
(216013, 'migrant', 'Ej bofast, migrerande.', 30, 'Spodoptera exigua'),
(216014, 'migrant', 'Ej bofast, migrerande.', 30, 'Spodoptera littoralis'),
(216291, 'migrant', 'Ej bofast, migrerande.', 30, 'Agrotis ipsilon'),
(216289, 'migrant', 'Ej bofast, migrerande.', 30, 'Euxoa ochrogaster'),

(6010412,'migrant', 'Ej bofast, migrerande.', 30, 'Aedia leucomelas'),
(215955, 'migrant', 'Ej bofast, migrerande.', 30, 'Chrysodeixis chalcites'),

(6010406,'migrant', 'Ej bofast, migrerande.', 30, 'Cornutiplusia circumflexa, marmormetallfly'),
(6010408,'migrant', 'Ej bofast, migrerande.', 30, 'Acontia lucida, sydglansfly'),
(102510,'migrant', 'Ej bofast, migrerande.', 30, 'Trichosea ludifica, gäck'),
(251247,'migrant', 'Ej bofast, migrerande.', 30, 'Chrysodeixis eriosoma, fikonmetallfly'),
(6009738,'migrant', 'Ej bofast, migrerande.', 30, 'Chrysodeixis keili, orkidémetallfly'),
(6010400,'migrant', 'Ej bofast, migrerande.', 30, 'Ctenoplusia limbirena , brunvattrat metallfly'),

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

(6010347, 'migrant', 'Ej bofast, migrerande.', 25, 'Diasemiopsis ramburialis, kåltropikmott'),
(233645, 'migrant', 'Ej bofast, migrerande.', 25, 'Mythimna languida, brokigt gräsfly'),
(216197, 'migrant', 'Ej bofast, migrerande.', 25, 'Mythimna unipuncta, vandrargräsfly'),
(6010439, 'migrant', 'Ej bofast, migrerande.', 25, 'Leucania loreyi, migrantgräsfly'),
(6010445, 'migrant', 'Ej bofast, migrerande.', 25, 'Euxoa lidia, klittjordfly'),
(232946, 'migrant', 'Ej bofast, migrerande.', 25, 'Agrotis bigramma, piltecknat jordfly'),
(6010442, 'migrant', 'Ej bofast, migrerande.', 25, 'Actebia fugax, vattrat stäppfly'),
(6010452, 'migrant', 'Ej bofast, migrerande.', 25, 'Xestia agathina, tegeljordfly'),
(101983 , 'migrant', 'Ej bofast, migrerande.', 25, 'Xestia ditrapezium, trapetsjordfly'),
(234296, 'migrant', 'Ej bofast, migrerande.', 25, 'Drymonia obliterata, bokflikvinge'),


-- Expanding / invasive / otherwise notable
(100328, 'editorial_note', 'Möjlig expansion i landskapet.', 25, 'Apatura iris'),
(100564, 'editorial_note', 'Särskilt intressant fynd.', 25, 'Catocala pacta'),
(6010418,'editorial_note', 'Särskilt intressant fynd.', 15, 'Mormo maura, Svartbandat ordensfly'),
(6331497,'editorial_note', 'Särskilt intressant fynd.', 15, 'Catephia alchymista, vitt ordensfly'),
(6010438, 'editorial_note', 'Särskilt intressant fynd.', 15, 'Mythimna favicolor, saltängsgräsfly, omstridd art'),

(6008270, 'invasive', 'Invasiv art att bevaka.', 30, 'Lindguldmal'),
(6010351, 'invasive', 'Invasiv art att bevaka.', 30, 'Buxbomsmott'),

(216335, 'editorial_note', 'Införd art.', 25, 'Cadra figulilella'),
(216336, 'editorial_note', 'Införd art.', 25, 'Cadra calidella'),
(216337, 'editorial_note', 'Införd art.', 25, 'Parapoynx bilinealis Rödbrämat akvariemott'),
(6010205,'editorial_note', 'Införd art.', 25, 'Gelechia senticetella, sydlig enstäppmal'),

-- Move last year's new_species_sk.sql into this list following years

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
(100372, 'editorial_note', 'Nyetablerad art.', 25, 'Apterona helicoidella, snäcksäckspinnare'), 
(6330903, 'editorial_note', 'Ny egen taxanomisk art', 25, 'Batrachedra confusella, tallsmalvingemal'),
(6010230, 'editorial_note', 'Nyetablerad art.', 25, 'Coleophora gardesanella, strandmalörtssäckmal'),
(214665, 'editorial_note', 'Nyetablerad art.', 25, 'Carpatolechia fugacella, bredvingad almkantmal'),
(6322612, 'editorial_note', 'Nyetablerad art.', 25, 'Xylomoia graminea,sumpugglefly'),
(6010275, 'editorial_note', 'Nyetablerad art.', 25, 'Hellinsia inulae, luddkrisslefjädermott'),


-- New in Skåne SOS db for any reasons (should be consistant with new_species_sk.sql)
--(216027, 'first_in_sk_sos_db', 'Första fyndet i den skånska SOS-databasen', 15, 'Kan finnas äldre ej digitaliserade fynd');
(214165, 'first_in_sk_sos_db', 'Första fyndet i artportalen detta år', 15, 'Argyresthia ivella'),
(100636, 'first_in_sk_sos_db', 'Första fyndet i artportalen detta år', 15, 'Chrysoclista lathamella'),
(214458, 'first_in_sk_sos_db', 'Första rapport i artportalen rapport detta år', 15, 'Coleophora juncicolella'),

-- Exceptional cases (should be consistant with new_species_sk.sql)
(6010380, 'new_for_sweden', 'Ny art för Sverige', 5, 'Stegania trimaculata'),
(6008327, 'new_for_sweden', 'Ny art för Sverige', 5, 'Phyllonorycter medicaginellus'),
(6010429, 'new_for_sweden', 'Ny art för Sverige', 5, 'Agrochola lunosa'),
(6332811, 'new_for_sweden', 'Ny art för Sverige', 5, 'Epiblema turbidana'),
(6332812, 'new_for_sweden', 'Ny art för Sverige', 5, 'Caloptilia honoratella');


COMMIT;
