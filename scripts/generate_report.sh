#!/usr/bin/env bash
set -Eeuo pipefail

SKLEPI_ROOT=$(git rev-parse --show-toplevel)
source "${SKLEPI_ROOT}/config/common.env"

GEN_REPORT_SQL="${1:-${SKLEPI_SQL_DIR}/editorial_report.sql}"

echo "Generate report"
sqlite3 "${SKLEPI_DB_PATH}" < "${GEN_REPORT_SQL}"

