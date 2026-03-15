-- file db_config_2025.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

-- USAGE: Create new file next year if needed!

-- report_formatted: true = markdown formatting (*species*, **NT**)

INSERT INTO config(key, value)
VALUES
    ('report_year', '2025'),
    ('province_id', '1'),
    ('report_formatted', 'true')
ON CONFLICT(key) DO UPDATE
SET value = excluded.value,
    updated_at = CURRENT_TIMESTAMP;
    
