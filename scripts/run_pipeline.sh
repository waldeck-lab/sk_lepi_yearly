#!/usr/bin/env bash
set -Eeuo pipefail

SKLEPI_ROOT=$(git rev-parse --show-toplevel)
source "${SKLEPI_ROOT}/config/common.env"

# Helpers
DB_CONFIG_SQL="${1:-${SKLEPI_SQL_DIR}/db_config_2025.sql}"
VIEW_CONFIG_SQL="${2:-${SKLEPI_SQL_DIR}/view_config_status.sql}"
NEW_YEARLY_SPECIES="${3:-${SKLEPI_SQL_DIR}/new_spec_sk_2025.sql}"
REPORT_SQL="${4:-${SKLEPI_SQL_DIR}/editorial_report.sql}"
STAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${SKLEPI_LOG_DIR}/pipeline_${STAMP}.log"
REPORT_FILE="${SKLEPI_OUTPUT_DIR}/report_${STAMP}.txt"

exec > >(tee -a "$LOG_FILE") 2>&1

trap 'rc=$?; echo "[ERROR] pipeline failed with exit code ${rc}"; exit "${rc}"' ERR

echo "[INFO] root:      ${SKLEPI_ROOT}"
echo "[INFO] db:        ${SKLEPI_DB_PATH}"
echo "[INFO] sql dir:   ${SKLEPI_SQL_DIR}"
echo "[INFO] log file:  ${LOG_FILE}"
echo "[INFO] cfg sql:   ${DB_CONFIG_SQL}"
echo "[INFO] report sql:${REPORT_SQL}"
echo "[INFO] started:   $(date -Iseconds)"

echo "[STEP] fetch or consolidate DWCA taxonomy"
bash "${SKLEPI_ROOT}/scripts/update_taxonomy.sh"

echo "[STEP] init schema"
python3 "${SKLEPI_SRC_DIR}/init_sqlite_db.py"

echo "[STEP] apply db config"
sqlite3 "${SKLEPI_DB_PATH}" < "${DB_CONFIG_SQL}"

echo "[STEP] view current config"
sqlite3 "${SKLEPI_DB_PATH}" < "${VIEW_CONFIG_SQL}"

echo "[STEP] add new species for this year"
sqlite3 "${SKLEPI_DB_PATH}" < "${NEW_YEARLY_SPECIES}"

echo "[STEP] import taxonomy"
python3 "${SKLEPI_SRC_DIR}/import_dyntaxa_dwca.py"

echo "[STEP] sync SOS"
python3 "${SKLEPI_SRC_DIR}/sync_sos_sqlite.py"

echo "[STEP] generate report"
sqlite3 "${SKLEPI_DB_PATH}" < "${REPORT_SQL}" > "${REPORT_FILE}"

echo "[OK] report: ${REPORT_FILE}"
echo "[OK] finished: $(date -Iseconds)"
