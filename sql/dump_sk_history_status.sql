-- file: sql/dump_sk_history_status.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

.headers on
.mode tabs

BEGIN;

SELECT * FROM v_skane_history_status;

COMMIT;
