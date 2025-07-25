-- Drop staging table if it exists
DROP TABLE IF EXISTS staging_othername_pfile;

-- Create staging table to match CSV file
CREATE TABLE staging_othername_pfile (
    npi VARCHAR(10),
    provider_other_organization_name VARCHAR(255),
    provider_other_organization_name_type_code CHAR(1)
);

-- Drop final target table if it exists
DROP TABLE IF EXISTS provider_othername;

-- Create final cleaned table
CREATE TABLE provider_othername (
    id SERIAL PRIMARY KEY,
    npi VARCHAR(10) NOT NULL,
    other_name VARCHAR(255) NOT NULL,
    name_type_code CHAR(1) NOT NULL,
    UNIQUE (npi, other_name, name_type_code)
);

-- Insert data from staging into final table
INSERT INTO provider_othername (npi, other_name, name_type_code)
SELECT DISTINCT
    npi,
    provider_other_organization_name,
    provider_other_organization_name_type_code
FROM staging_othername_pfile
WHERE
    npi IS NOT NULL AND npi <> ''
    AND provider_other_organization_name IS NOT NULL AND provider_other_organization_name <> ''
    AND provider_other_organization_name_type_code IN ('3', '4', '5');
