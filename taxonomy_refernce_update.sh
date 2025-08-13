#!/usr/bin/env bash
set -euo pipefail

############################################
# CONFIG — edit to your environment
############################################
PAGE_URL="https://www.nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/csv-mainmenu-57"

# Where to store files (fixed location on Windows C: drive via WSL)
DATA_DIR="/mnt/e/Course_Work_CMU/Internship/EMRTS/P4_Data/Clean_data"
RAW_CSV="${DATA_DIR}/nucc_taxonomy_raw.csv"
CLEAN_CSV="${DATA_DIR}/nucc_taxonomy_cleaned.csv"

# DB connection (use .pgpass or PGPASSWORD if needed)
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="provider_management"
DB_USER="hetong"

# Path to the cleaner script (Python)
CLEANER_SCRIPT="./clean_nucc_taxonomy.py"   # change if located elsewhere
############################################

echo "==> Ensuring data directory exists: ${DATA_DIR}"
mkdir -p "${DATA_DIR}"

echo "==> Checking prerequisites..."
command -v curl >/dev/null 2>&1 || { echo "curl not found."; exit 1; }
command -v psql >/dev/null 2>&1 || { echo "psql not found."; exit 1; }
command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || { echo "python not found."; exit 1; }
[[ -f "${CLEANER_SCRIPT}" ]] || { echo "Cleaner script not found at ${CLEANER_SCRIPT}"; exit 1; }

echo "==> Fetching download page..."
PAGE_CONTENT="$(curl -s "${PAGE_URL}")"

echo "==> Locating latest NUCC taxonomy CSV link..."
CSV_URL="$(echo "${PAGE_CONTENT}" \
  | grep -oP 'href="\K[^"]*nucc_taxonomy_[0-9]+\.csv' \
  | sort -t'_' -k3,3nr \
  | head -1)"

if [[ -z "${CSV_URL}" ]]; then
  echo "ERROR: Could not find a nucc_taxonomy_*.csv link on the page."
  exit 1
fi

# Make absolute if needed
if [[ "${CSV_URL}" != http* ]]; then
  CSV_URL="https://www.nucc.org/${CSV_URL}"
fi

echo "==> Latest CSV: ${CSV_URL}"
echo "==> Downloading to: ${RAW_CSV}"
curl -L -o "${RAW_CSV}" "${CSV_URL}"

# Prefer python3 if available
PYBIN=$(command -v python3 || command -v python)

echo "==> Cleaning CSV (keep taxonomy_code, specialization, definition; fill blanks with N/A)..."
"${PYBIN}" "${CLEANER_SCRIPT}" "${RAW_CSV}" "${CLEAN_CSV}"

PSQL_CONN=( psql -h "${DB_HOST}" -p "${DB_PORT}" -d "${DB_NAME}" -U "${DB_USER}" )

echo "==> Truncating taxonomy_reference (and resetting identity)..."
"${PSQL_CONN[@]}" -c "TRUNCATE TABLE taxonomy_reference RESTART IDENTITY;"

echo "==> Loading cleaned CSV into taxonomy_reference..."
"${PSQL_CONN[@]}" -c "\copy taxonomy_reference(taxonomy_code,specialization,definition) FROM '${CLEAN_CSV}' WITH (FORMAT csv, HEADER true, DELIMITER ',');"

echo "==> Done. New taxonomy loaded from: ${CLEAN_CSV}"
