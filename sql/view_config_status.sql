-- file: sql/view_config_status.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

.headers on
.mode column

BEGIN;

SELECT * FROM v_config_status;

COMMIT; 
