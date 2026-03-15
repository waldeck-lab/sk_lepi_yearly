-- file db_config_2025.sql
-- create new file next year if needed!
INSERT INTO config(key, value) VALUES ('report_year', '2025')
ON CONFLICT(key) DO UPDATE SET value=excluded.value, updated_at=CURRENT_TIMESTAMP;

INSERT INTO config(key, value) VALUES ('province_id', '1')
ON CONFLICT(key) DO UPDATE SET value=excluded.value, updated_at=CURRENT_TIMESTAMP;


