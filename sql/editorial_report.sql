-- file: sql/editorial_report.sql

-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Jonas Waldeck

-- USAGE: Run this first after populate/consolidating the db for the relevant year

BEGIN;

SELECT line FROM v_report_output;

COMMIT; 
