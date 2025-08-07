# Table of Contents
- [Introduction](#nppes-database-from-emrts)
- [Prerequisites](#prerequisites)
- [Makefile](#makefile)
- [Running pgAdmin4 server](#running-pgadmin4-server) *(optional for this project)*
  - [Setting up a postgres Web Application](#setting-up-a-postgres-web-application)
  - [Running the application](#running-the-application)
  - [How to use with Gunicorn](#how-to-use-with-gunicorn)

# NPPES Database from EMRTS
The Purpose of this project is to perform ETL (Extract, Transfer, and Load) from the NPPES zip file to a Postgres database.

## Prerequisites:
* Windows:
  - Install WSL (Windows Subsystem for Linux):
  > Note: In Windows, you must be inside the WSL terminal for this project (Type `wsl` in the terminal to be inside of it)
    1. Open PowerShell as Administrator and run: `wsl --install`
    2. Restart your computer when prompted
    3. When your computer restarts, WSL will continue installation and ask you to create a username and password for Ubuntu
    4. After setup completes, you'll have Ubuntu running on Windows.
  - Make inside WSL
    1. Install using this command: `sudo apt install make`
* macOS:
  - Install make using Homebrew (install Homebrew first if not installed):
    ```bash
    brew install make
    ```

**The program also needs an info.json file for the database, copy the info_template.json to info.json and put in the information for your database.**

## Makefile
The project uses a Makefile to simplify common operations. Here are the available commands:

* `make check_packages` - Verifies all required dependencies are installed before running the program
* `make test` - Run all tests once run is completed
* `make clear_NPPES_data` - Clear Original_data directory once run is finished
* `make clear_db` - Clear all tables and types from the current database
* `make run` - Run the shell script automate_data_fetching.sh which performs ETL (Extract, Transfer, and Load)
* `make help` - Runs all commands for the make file

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