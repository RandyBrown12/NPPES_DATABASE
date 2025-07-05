#!/usr/bin/sh

# -------------------------------------------------------
# 
# File: automate_data_fetching.sh
#
# Description: Automate Data fetching with a
# cron-job that fetches NPPES data every month
# and grabs the specific csv files.
#
# Developer: Randy Brown
# Developer Email: randybrown9812@gmail.com
# 
# Version 1.0
# Initialed Bash Script for this
#
# -------------------------------------------------------

MONTH=$(date -d "$(date +%Y-%m-01) -1 month" +%B)
YEAR=$(date +%Y)

DATA_LINK="https://download.cms.gov/nppes/NPPES_Data_Dissemination_${MONTH}_${YEAR}_V2.zip"
DEST_ZIP="NPPES_Data_Dissemination_${MONTH}_${YEAR}_V2.zip"
cd Original_data || exit 1

curl -o "$DEST_ZIP" "$DATA_LINK"

unzip "$DEST_ZIP"

rm "$DEST_ZIP"