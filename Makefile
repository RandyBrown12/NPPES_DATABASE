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
		echo "✅ All needed packages have been successfully installed!"; \
	else \
		echo "⛔ Some packages are missing. Please install them before continuing. ⛔"; \
	fi

test:
	pytest "$(current_directory)/tests.py"

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