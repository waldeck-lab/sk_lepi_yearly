-- file sql/2025/db_config.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

-- USAGE: Create new file next year if needed!

-- report_formatted: true = markdown formatting (*species*, **NT**)

.headers on
.mode column

BEGIN;

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

-- Group all families that shares the same Swedish family name
UPDATE app_config
SET config_value = 'true'
WHERE config_key = 'merge_family_headers_by_sv_alias';

UPDATE app_config
SET config_value = 'first_in_skane,first_in_sk_sos_db,new_for_sweden,migrant,invasive,range_expansion,editorial_note'
WHERE config_key = 'visible_reason_codes';

-- Set concatenation level to limit observations to few relevant ones, best 3,
--  but in range 2-5 for small or larger report
UPDATE app_config
SET config_value = '3'
WHERE config_key = 'obs_detail_limit';

UPDATE app_config
SET config_value = '16'
WHERE config_key = 'obs_summary_threshold';

SELECT printf(
    'CONFIG: year=%s formatted=%s verbose=%s few_obs_threshold=%s obs_summary_threshold=%s merge_family_headers=%s visible_reason_codes=%s',
    report_year,
    formatted_output,
    verbose_output,
    few_obs_threshold,
    obs_summary_threshold,
    merge_family_headers,
    visible_reason_codes
)
FROM v_config_status;

COMMIT;
