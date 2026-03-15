-- file db_config_2025.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

-- USAGE: Create new file next year if needed!

-- report_formatted: true = markdown formatting (*species*, **NT**)

.headers on
.mode column

UPDATE app_config
SET config_value = '2025'
WHERE config_key = 'report_year';

UPDATE app_config
SET config_value = 'true'
WHERE config_key = 'report_formatted';

SELECT 'CONFIG: report_year=' || report_year ||
       ' formatted=' || formatted_output
FROM v_config_status;
