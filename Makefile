# All packages in Linux that you need
needed_packages=make curl jq python psql pytest unzip 

current_directory := $(shell pwd)

check_packages:
	@all_packages_installed=true; \
	for package in $(needed_packages); do \
		if ! command -v $$package >/dev/null 2>&1; then \
			echo "$$package is not installed on this computer. Install by doing: sudo apt-get install $$package"; \
			all_packages_installed=false; \
		fi; \
	done; \
	if [ "$$all_packages_installed" = "true" ]; then \
		echo "✅ All needed packages have been successfully installed! ✅"; \
	else \
		echo "⛔ Some packages are missing. Please install them before continuing. ⛔"; \
	fi

test:
	pytest "$(current_directory)/tests/test_database.py"
	pytest "$(current_directory)/tests/test_db_staging.py"

clear_NPPES_data:
	@echo "Removing Original_data directory in this repository"
	@rm -rf "$(current_directory)/Original_data"

clear_db:
	@echo "Cleaning data from database"
	@info_json_location="$(current_directory)/info.json"; \
	db_name=$$(jq -r '.database' $$info_json_location); \
	db_username=$$(jq -r '.user' $$info_json_location); \
	db_password=$$(jq -r '.password' $$info_json_location); \
	db_host=$$(jq -r '.host' $$info_json_location); \
	db_port=$$(jq -r '.port' $$info_json_location); \
	psql "postgresql://$$db_username:$$db_password@$$db_host:$$db_port/$$db_name" -f "$(current_directory)/db/drop_tables.sql"

run_NPPES:
	"$(current_directory)/lib/NPPES_data_fetching.sh"

run_taxonomy:
	"$(current_directory)/lib/taxonomy_data_fetching.sh"

help:
	@echo "Command: make [target] [...target] "
	@echo "Available targets:";
	@echo " check_packages - Verify all packages are installed on your computer before proceeding "
	@echo " test - Verify all packages are installed on your computer before proceeding "
	@echo " clean_NPPES_data - Clear the Original_data directory when the run command is finished "
	@echo " clean_db - Drop all the tables and types in the database "
	@echo " run - Run the main script which performs ETL (Extract, Transfer, Load) into the database "
	@echo " summary - Print out a summary of provider data "

summary:
	@python "$(current_directory)/lib/summary.py"