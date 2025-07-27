-- Script to create the pl_data table and load data from CSV

CREATE TABLE pl_data (
    npi TEXT,
    entity_type_code INTEGER,
    replacement_npi TEXT,
    ein TEXT,
    organization_name TEXT,
    last_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    name_prefix TEXT,
    name_suffix TEXT,
    credential TEXT,
    gender TEXT,
    enumeration_date DATE,
    last_update_date DATE,
    deactivation_date DATE,
    reactivation_date DATE,
    address_line_1 TEXT,
    address_line_2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country_code TEXT,
    phone_number TEXT,
    fax_number TEXT
    -- (You may continue adding more columns if your full file includes them)
);

\COPY pl_data FROM 'path/to/pl_pfile_20050523-20250608.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    NULL ''
);

