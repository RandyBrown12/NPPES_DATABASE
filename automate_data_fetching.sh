#!/usr/bin/sh

# -------------------------------------------------------
# 
# File: automate_data_fetching.sh
#
# Description: Automate Data fetching with a
# cron-job that fetches NPPES data every month
# and grabs the specific csv files.
#
#
# Developer: Randy Brown
# Developer Email: randybrown9812@gmail.com
# 
# Version 1.0
# Initialed Bash Script for this
#
# -------------------------------------------------------
current_directory=$(pwd)

# Grab the current month and year for NPPES database
MONTH=$(date -d "$(date +%Y-%m-01) -1 month" +%B)
YEAR=$(date +%Y)

info_json_location="$current_directory/info.json"

# Grab Database information
db_name=$(jq -r '.database' "$info_json_location")
db_username=$(jq -r '.user' "$info_json_location")
db_password=$(jq -r '.password' "$info_json_location")
db_host=$(jq -r '.host' "$info_json_location")
db_port=$(jq -r '.port' "$info_json_location")


DATA_LINK="https://download.cms.gov/nppes/NPPES_Data_Dissemination_${MONTH}_${YEAR}_V2.zip"
DEST_ZIP="NPPES_Data_Dissemination_${MONTH}_${YEAR}_V2.zip"

mkdir -p Original_data

cd Original_data || exit 1

# Grab a link to use with curl from the data link site.
curl -o "$DEST_ZIP" "$DATA_LINK"

unzip "$DEST_ZIP"

rm "$DEST_ZIP"

# Grab CSV names for each file
npi_csv_filepath=$(find "$current_directory/Original_data" -type f | grep -E 'npidata_pfile_[0-9]{8}-[0-9]{8}\.csv')
endpoint_csv_filepath=$(find "$current_directory/Original_data" -type f | grep -E 'endpoint_pfile_[0-9]{8}-[0-9]{8}\.csv')
othername_csv_filepath=$(find "$current_directory/Original_data" -type f | grep -E 'othername_pfile_[0-9]{8}-[0-9]{8}\.csv')
pl_csv_filepath=$(find "$current_directory/Original_data" -type f | grep -E 'pl_pfile_[0-9]{8}-[0-9]{8}\.csv')

# Load the schema file
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -f "$current_directory/db/schema.sql"

# Perform data cleaning for the 4 files
python "$current_directory/db_staging.py" -i "$npi_csv_filepath" -o "npidata_cleaned.csv" -p 4
python "$current_directory/db_staging.py" -i "$endpoint_csv_filepath" -o "endpoint_cleaned.csv" -p 4
python "$current_directory/db_staging.py" -i "$othername_csv_filepath" -o "othername_cleaned.csv" -p 4
python "$current_directory/db_staging.py" -i "$pl_csv_filepath" -o "pl_cleaned.csv" -p 4

# Perform COPY commands
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -c "\COPY STAGING_TABLE_ENDPOINTS FROM '$current_directory/Original_data/endpoint_cleaned.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"')"
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -c "\COPY STAGING_TABLE_NPI FROM '$current_directory/Original_data/npidata_cleaned.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"')"
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -c "\COPY STAGING_OTHERNAME_PFILE FROM '$current_directory/Original_data/othername_cleaned.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"')"
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -c "\COPY provider_secondary_practice_location (npi, address_line1, address_line2, city_name, state_name, postal_code, country_code, telephone_number, telephone_extension, fax_number) FROM '$current_directory/Original_data/pl_cleaned.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"')"

# Perform data loading
psql "postgresql://$db_username:$db_password@$db_host:$db_port/$db_name" -f "$current_directory/db/load_data.sql"

echo "automate_data_fetching.sh has been finished!"