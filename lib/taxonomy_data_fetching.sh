#!/usr/bin/env bash
set -euo pipefail

############################################
# CONFIG — edit to your environment
############################################
PAGE_URL="https://www.nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/csv-mainmenu-57"

# Where to store files (fixed location on Windows C: drive via WSL)
current_directory=$(pwd)
DATA_DIR="$current_directory/Original_data"
RAW_CSV="${DATA_DIR}/nucc_taxonomy_raw.csv"
CLEAN_CSV="${DATA_DIR}/nucc_taxonomy_cleaned.csv"

info_json_location="$current_directory/info.json"

# DB connection (use .pgpass or PGPASSWORD if needed)
db_name=$(jq -r '.database' "$info_json_location")
db_username=$(jq -r '.user' "$info_json_location")
db_password=$(jq -r '.password' "$info_json_location")
db_host=$(jq -r '.host' "$info_json_location")
db_port=$(jq -r '.port' "$info_json_location")

# Path to the cleaner script (Python)
CLEANER_SCRIPT="$current_directory/lib/clean_nucc_taxonomy.py"   # change if located elsewhere
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

echo "==> Truncating taxonomy_reference (and resetting identity)..."
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -c "TRUNCATE TABLE taxonomy_reference RESTART IDENTITY;"

echo "==> Loading cleaned CSV into taxonomy_reference..."
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -c "\copy taxonomy_reference(taxonomy_code,specialization,definition) FROM '${CLEAN_CSV}' WITH (FORMAT csv, HEADER true, DELIMITER ',');"

echo "==> Done. New taxonomy loaded from: ${CLEAN_CSV}"
