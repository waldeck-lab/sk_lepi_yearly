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

UPDATE app_config
SET config_value = 'false'
WHERE config_key = 'verbose_output';

-- threashold to show species with only few observations, 0 for disable
UPDATE app_config
SET config_value = '0'
WHERE config_key = 'few_observations_threshold';


SELECT printf(
    'CONFIG: year=%s formatted=%s verbose=%s obs_threshold=%d',
    report_year,
    formatted_output,
    verbose_output,
    few_obs_threshold
)
FROM v_config_status;
