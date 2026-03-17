-- file: sql/dump_manually_injected_taxons.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

.headers on
.mode tabs

BEGIN; 

SELECT * FROM v_manual_flags_status;

COMMIT;
