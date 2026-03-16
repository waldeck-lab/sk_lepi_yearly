-- file: ../sql/manual_insert_2025.sql
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
--  * Keep reason_code short, machine-friendly, stable
--  * Keep reason_text human-readable; this may appear in report metadata
--
-- Suggested priority scale:
--   5   = exceptional (e.g. new for Sweden)
--   10  = first in Scania
--   20  = strong editorial reason
--   30  = notable rarity / migrant / expansion
--   50  = general manual editorial inclusion
--
-- Example inserts are commented out below.

BEGIN;

-- Examples:
-- INSERT OR IGNORE INTO species_manual_flags
-- (taxon_id, scientific_name, reason_code, reason_text, priority, note)
-- VALUES
-- (100328, 'Apatura iris', 'editorial_note', 'Särskilt intressant fynd', 25, 'Kort motivering'),
-- (101366, 'Mythimna turca', 'range_expansion', 'Möjlig expansion i landskapet', 30, 'Bedöms vara intressant trots få fynd'),
-- (216027, 'Chloantha hyperici', 'rare_migrant', 'Sällsynt migrant', 20, 'Manuell bedömning'),
-- (214165, 'Argyresthia ivella', 'new_for_sweden', 'Ny art för Sverige', 5, 'Om detta skulle bli aktuellt');

COMMIT;
