# Table of Contents
- [Introduction](#nppes-database-from-emrts)
- [Fetching the data](#fetching-the-nppes-data-using-dbtestsh)
- [Pre-loading the data](#pre-loading-the-data)
  - [Through pgAdmin4](#pre-loading-the-data-through-pgadmin4)
  - [Through psql](#pre-loading-the-data-through-psql)
- [Loading the data](#loading-the-data)
  - [Through pgAdmin4](#loading-the-data-through-pgadmin4)
  - [Through psql](#loading-the-data-through-psql)
- [Running pgAdmin4 server](#running-pgadmin4-server) *(optional for this project)*
  - [Setting up a postgres Web Application](#setting-up-a-postgres-web-application)
  - [Running the application](#running-the-application)
  - [How to use with Gunicorn](#how-to-use-with-gunicorn)

# NPPES Database from EMRTS
The Purpose of this project is to perform ETL (Extract, Transfer, and Load) from the NPPES zip file to a Postgres database.

## Fetching the NPPES data using db/test.sh.
This file is to be run aloneside a crontab to automate this every month.
Make sure an Original_data directory is in the repository directory.
Command: `./db/test.sh`

## Pre-loading the data

### Pre-loading the data through pgAdmin4
Access your Database through pgAdmin4 and use the query tool.
Once inside, copy the contents of schema.sql into the query tool and execute the script.

### Pre-loading the data through psql
Run this command: `psql -U <username> -d <database> -f db/schema.sql`

## Loading the data

### Loading the data through pgAdmin4
Once inside, go into the tables that start with staging and select Import/Export Data.
> Note: Make sure values from csv file (Ex. ,"",) are changed to have nothing (Ex. ,,). This can be done by just saving through excel or
        you can use this command `sed 's/""//g' endpoint_pfile_XXXXXXXX-XXXXXXXX.csv > endpoint_cleaned.csv` but note that "" values in your data will be replaced.

> Note: For STAGING_TABLE_NPI, You must run db_staging.py by doing `python db_staging.py` and change input_csv variable inside the file to the path of npidata_pfile_XXXXXXXX-XXXXXXXX.csv

**The settings will be as followed:**

General
- Import
- Filename: <file_to_endpoint_pfile_csv>
- Format: csv

Options
- Header ON (tab is blue)
- Delimiter: ,
- Quote: "
- Escape: 
- NULL strings: 

Once you have copied all the data into the staging tables, you can use the query tool to run load_data.sql

### Loading the data through psql

Enter credientials to access the database and copy all the staging tables from the correct NPPES csv file not containing fileheader.

Ex: ```\COPY STAGING_TABLE_<NAME> FROM '</path/to/.csv>' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', NULL '');
> Note: For STAGING_TABLE_NPI, You must run db_staging.py by doing `python db_staging.py` and change input_csv variable inside the file to the path of npidata_pfile_XXXXXXXX-XXXXXXXX.csv

Once you have copied all the data into the staging tables, you can perform the command to run load_data.sql `psql -U <username> -d <database> -f db/load_data.sql`

## Running pgAdmin4 server

### Setting up a Postgres web application
1. Add a virtual environment
Command: `python -m venv .venv`
2. Activate the virtual environment
Command: `source .venv/bin/activate`
3. Install packages through uv
Command: `uv pip install -r requirements.txt`
4. Create a directory to store postgres web app information.
Command: `mkdir pg_data`
5. Insert a config_local.py in pgadmin4 directory for using pg_data directory with the contents. The directory is found in the lib64 folder
```python
import os

DATA_DIR = os.path.join(os.getcwd(), 'pg_data')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SERVER_MODE = True
```

### Running the application
To run the application run the command
`python <path_to_pgadmin4.py_in_venv>`

You can now access the postgres server


### How to use with Gunicorn
```
gunicorn --bind unix:/tmp/pgadmin4.sock \
         --workers=1 \
         --threads=25 \
         --chdir ~/NPPES/.venv/lib64/python3.12/site-packages/pgadmin4 \
         pgAdmin4:app
```