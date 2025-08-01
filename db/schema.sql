--# Tables
CREATE TYPE YES_OR_NO AS ENUM ('Y','N','X');

--# Providers File
-- 1. Providers table (npi as PK)
CREATE TABLE providers (
    id BIGSERIAL PRIMARY KEY,
    npi BIGINT UNIQUE NOT NULL,
    entity_type_code VARCHAR(3) NOT NULL,
    replacement_npi BIGINT NOT NULL,
    employer_identification_number VARCHAR(20) NOT NULL,
    provider_organization_name VARCHAR(200) NOT NULL,
    provider_last_name VARCHAR(100) NOT NULL,
    provider_first_name VARCHAR(100) NOT NULL,
    provider_middle_name VARCHAR(100) NOT NULL,
    provider_name_prefix_text VARCHAR(20) NOT NULL,
    provider_name_suffix_text VARCHAR(20) NOT NULL,
    provider_credential_text VARCHAR(50) NOT NULL,
    provider_other_organization_name VARCHAR(200) NOT NULL,
    provider_other_organization_name_type_code VARCHAR(3) NOT NULL,
    provider_other_last_name VARCHAR(100) NOT NULL,
    provider_other_first_name VARCHAR(100) NOT NULL,
    provider_other_middle_name VARCHAR(100) NOT NULL,
    provider_other_name_prefix_text VARCHAR(20) NOT NULL,
    provider_other_name_suffix_text VARCHAR(20) NOT NULL,
    provider_other_credential_text VARCHAR(50) NOT NULL,
    provider_other_last_name_type_code VARCHAR(3) NOT NULL,
    provider_enumeration_date DATE NOT NULL,
    last_update_date DATE NOT NULL,
    npi_deactivation_reason_code VARCHAR(3) NOT NULL,
    npi_deactivation_date DATE NOT NULL,
    npi_reactivation_date DATE NOT NULL,
    provider_sex_code VARCHAR(1) NOT NULL,
    is_sole_proprietor YES_OR_NO NOT NULL,
    is_organization_subpart YES_OR_NO NOT NULL,
    parent_organization_lbn VARCHAR(200) NOT NULL,
    parent_organization_tin VARCHAR(20) NOT NULL,
    certification_date DATE NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. provider_taxonomy table 
CREATE TABLE provider_taxonomy (
    id SERIAL PRIMARY KEY,
    provider_id BIGINT NOT NULL REFERENCES providers(id),
    taxonomy_order INT NOT NULL, -- 1 to 15, corresponds to _1..._15
    taxonomy_code VARCHAR(20) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    license_number_state_code VARCHAR(5) NOT NULL,
    primary_taxonomy_switch VARCHAR(1) NOT NULL,
    taxonomy_group VARCHAR(100) NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. provider_address table 
CREATE TABLE provider_address (
    id SERIAL PRIMARY KEY,
    provider_id BIGINT NOT NULL REFERENCES providers(id),
    address_type VARCHAR(30) NOT NULL, -- e.g., 'mailing', 'practice'
    first_line VARCHAR(200) NOT NULL,
    second_line VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country_code VARCHAR(5) NOT NULL,
    telephone_number VARCHAR(20) NOT NULL,
    fax_number VARCHAR(20) NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. provider_other_identifier table 
CREATE TABLE provider_other_identifier (
    id SERIAL PRIMARY KEY,
    provider_id BIGINT NOT NULL REFERENCES providers(id),
    identifier_order INT NOT NULL, -- 1 to 50, corresponds to _1..._50
    other_provider_identifier VARCHAR(1000) NOT NULL,
    type_code VARCHAR(10) NOT NULL,
    state VARCHAR(5) NOT NULL,
    issuer VARCHAR(200) NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. provider_authorized_official (npi as PK)
CREATE TABLE provider_authorized_official (
    id BIGSERIAL PRIMARY KEY,
    provider_id BIGINT NOT NULL REFERENCES providers(id),
    npi BIGINT NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100) NOT NULL,
    title_or_position VARCHAR(100) NOT NULL,
    telephone_number VARCHAR(20) NOT NULL,
    name_prefix_text VARCHAR(20) NOT NULL,
    name_suffix_text VARCHAR(20) NOT NULL,
    credential_text VARCHAR(50) NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
);

-- 6. taxonomy_reference (taxonomy_code as PK)
CREATE TABLE taxonomy_reference (
    id BIGSERIAL PRIMARY KEY,
    taxonomy_code VARCHAR(20) NOT NULL,
    specialization VARCHAR(255) NOT NULL,
    definition TEXT NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

--# Endpoints File
CREATE TABLE IF NOT EXISTS ENDPOINT_AFFILIATION(
    AFFILIATION_ID SERIAL PRIMARY KEY,
    AFFILIATION_PRIMARY_ADDRESS VARCHAR(55) NOT NULL DEFAULT 'N/A',
    AFFILIATION_SECONDARY_ADDRESS VARCHAR(55) NOT NULL DEFAULT 'N/A',
    AFFILIATION_ADDRESS_CITY VARCHAR(40) NOT NULL DEFAULT 'N/A',
    AFFILIATION_ADDRESS_STATE VARCHAR(40) NOT NULL DEFAULT 'N/A',
    AFFILIATION_ADDRESS_COUNTRY CHAR(2) NOT NULL DEFAULT 'XX',
    AFFILIATION_ADDRESS_POSTAL_CODE VARCHAR(15) NOT NULL DEFAULT '000000000',
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ENDPOINTS(
    ENDPOINT_ID SERIAL PRIMARY KEY,
    NPI BIGINT NOT NULL REFERENCES providers(npi),
    ENDPOINT_TYPE VARCHAR(50) NOT NULL,
    ENDPOINT_TYPE_DESCRIPTION VARCHAR(50) NOT NULL DEFAULT 'N/A',
    ENDPOINT VARCHAR(1000) NOT NULL DEFAULT 'N/A',
    AFFILIATION YES_OR_NO NOT NULL DEFAULT 'X',
    AFFILIATION_ID INT NOT NULL,
    ENDPOINT_DESCRIPTION VARCHAR(1000) NOT NULL DEFAULT 'N/A',
    BUSINESS_NAME VARCHAR(100) NOT NULL DEFAULT 'N/A',
    USE_CODE VARCHAR(25) NOT NULL DEFAULT 'N/A',
    USE_DESCRIPTION VARCHAR(100) NOT NULL DEFAULT 'N/A',
    OTHER_USE_DESCRIPTION VARCHAR(200) NOT NULL DEFAULT 'N/A',
    CONTENT_TYPE VARCHAR(25) NOT NULL DEFAULT 'N/A',
    CONTENT_DESCRIPTION VARCHAR(100) NOT NULL DEFAULT 'N/A',
    OTHER_CONTENT_DESCRIPTION VARCHAR(200) NOT NULL DEFAULT 'N/A',
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (AFFILIATION_ID) REFERENCES ENDPOINT_AFFILIATION(AFFILIATION_ID)
);

--# Othername File
-- Drop final target table if it exists
DROP TABLE IF EXISTS provider_othername;

-- Create final cleaned table
CREATE TABLE provider_othername (
    id SERIAL PRIMARY KEY,
    npi VARCHAR(10) NOT NULL,
    other_name VARCHAR(255) NOT NULL,
    name_type_code CHAR(1) NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (npi, other_name, name_type_code)
);

--# STAGING TABLES:

CREATE TABLE IF NOT EXISTS STAGING_TABLE_ENDPOINTS(
    NPI BIGINT NOT NULL,
    ENDPOINT_TYPE VARCHAR(50) NOT NULL,
    ENDPOINT_TYPE_DESCRIPTION VARCHAR(50),
    ENDPOINT VARCHAR(1000),
    AFFILIATION YES_OR_NO,
    ENDPOINT_DESCRIPTION VARCHAR(1000),
    BUSINESS_NAME VARCHAR(100),
    USE_CODE VARCHAR(25),
    USE_DESCRIPTION VARCHAR(100),
    OTHER_USE_DESCRIPTION VARCHAR(200),
    CONTENT_TYPE VARCHAR(25),
    CONTENT_DESCRIPTION VARCHAR(100),
    OTHER_CONTENT_DESCRIPTION VARCHAR(200),
    AFFILIATION_PRIMARY_ADDRESS VARCHAR(55),
    AFFILIATION_SECONDARY_ADDRESS VARCHAR(55),
    AFFILIATION_ADDRESS_CITY VARCHAR(40),
    AFFILIATION_ADDRESS_STATE VARCHAR(40),
    AFFILIATION_ADDRESS_COUNTRY CHAR(2),
    AFFILIATION_ADDRESS_POSTAL_CODE VARCHAR
);

CREATE TABLE STAGING_TABLE_NPI (
    "NPI" TEXT,
    "Entity_Type_Code" TEXT,
    "Replacement_NPI" TEXT,
    "Employer_Identification_Number_EIN" TEXT,
    "Provider_Organization_Name_Legal_Business_Name" TEXT,
    "Provider_Last_Name_Legal_Name" TEXT,
    "Provider_First_Name" TEXT,
    "Provider_Middle_Name" TEXT,
    "Provider_Name_Prefix_Text" TEXT,
    "Provider_Name_Suffix_Text" TEXT,
    "Provider_Credential_Text" TEXT,
    "Provider_Other_Organization_Name" TEXT,
    "Provider_Other_Organization_Name_Type_Code" TEXT,
    "Provider_Other_Last_Name" TEXT,
    "Provider_Other_First_Name" TEXT,
    "Provider_Other_Middle_Name" TEXT,
    "Provider_Other_Name_Prefix_Text" TEXT,
    "Provider_Other_Name_Suffix_Text" TEXT,
    "Provider_Other_Credential_Text" TEXT,
    "Provider_Other_Last_Name_Type_Code" TEXT,
    "Provider_First_Line_Business_Mailing_Address" TEXT,
    "Provider_Second_Line_Business_Mailing_Address" TEXT,
    "Provider_Business_Mailing_Address_City_Name" TEXT,
    "Provider_Business_Mailing_Address_State_Name" TEXT,
    "Provider_Business_Mailing_Address_Postal_Code" TEXT,
    "Provider_Business_Mailing_Address_Country_Code_If_outside_U_S_" TEXT,
    "Provider_Business_Mailing_Address_Telephone_Number" TEXT,
    "Provider_Business_Mailing_Address_Fax_Number" TEXT,
    "Provider_First_Line_Business_Practice_Location_Address" TEXT,
    "Provider_Second_Line_Business_Practice_Location_Address" TEXT,
    "Provider_Business_Practice_Location_Address_City_Name" TEXT,
    "Provider_Business_Practice_Location_Address_State_Name" TEXT,
    "Provider_Business_Practice_Location_Address_Postal_Code" TEXT,
    "Provider_Business_Practice_Location_Address_Country_Code_If_outside_U_S_" TEXT,
    "Provider_Business_Practice_Location_Address_Telephone_Number" TEXT,
    "Provider_Business_Practice_Location_Address_Fax_Number" TEXT,
    "Provider_Enumeration_Date" TEXT,
    "Last_Update_Date" TEXT,
    "NPI_Deactivation_Reason_Code" TEXT,
    "NPI_Deactivation_Date" TEXT,
    "NPI_Reactivation_Date" TEXT,
    "Provider_Sex_Code" TEXT,
    "Authorized_Official_Last_Name" TEXT,
    "Authorized_Official_First_Name" TEXT,
    "Authorized_Official_Middle_Name" TEXT,
    "Authorized_Official_Title_or_Position" TEXT,
    "Authorized_Official_Telephone_Number" TEXT,
    "Healthcare_Provider_Taxonomy_Code_1" TEXT,
    "Provider_License_Number_1" TEXT,
    "Provider_License_Number_State_Code_1" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_1" TEXT,
    "Healthcare_Provider_Taxonomy_Code_2" TEXT,
    "Provider_License_Number_2" TEXT,
    "Provider_License_Number_State_Code_2" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_2" TEXT,
    "Healthcare_Provider_Taxonomy_Code_3" TEXT,
    "Provider_License_Number_3" TEXT,
    "Provider_License_Number_State_Code_3" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_3" TEXT,
    "Healthcare_Provider_Taxonomy_Code_4" TEXT,
    "Provider_License_Number_4" TEXT,
    "Provider_License_Number_State_Code_4" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_4" TEXT,
    "Healthcare_Provider_Taxonomy_Code_5" TEXT,
    "Provider_License_Number_5" TEXT,
    "Provider_License_Number_State_Code_5" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_5" TEXT,
    "Healthcare_Provider_Taxonomy_Code_6" TEXT,
    "Provider_License_Number_6" TEXT,
    "Provider_License_Number_State_Code_6" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_6" TEXT,
    "Healthcare_Provider_Taxonomy_Code_7" TEXT,
    "Provider_License_Number_7" TEXT,
    "Provider_License_Number_State_Code_7" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_7" TEXT,
    "Healthcare_Provider_Taxonomy_Code_8" TEXT,
    "Provider_License_Number_8" TEXT,
    "Provider_License_Number_State_Code_8" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_8" TEXT,
    "Healthcare_Provider_Taxonomy_Code_9" TEXT,
    "Provider_License_Number_9" TEXT,
    "Provider_License_Number_State_Code_9" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_9" TEXT,
    "Healthcare_Provider_Taxonomy_Code_10" TEXT,
    "Provider_License_Number_10" TEXT,
    "Provider_License_Number_State_Code_10" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_10" TEXT,
    "Healthcare_Provider_Taxonomy_Code_11" TEXT,
    "Provider_License_Number_11" TEXT,
    "Provider_License_Number_State_Code_11" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_11" TEXT,
    "Healthcare_Provider_Taxonomy_Code_12" TEXT,
    "Provider_License_Number_12" TEXT,
    "Provider_License_Number_State_Code_12" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_12" TEXT,
    "Healthcare_Provider_Taxonomy_Code_13" TEXT,
    "Provider_License_Number_13" TEXT,
    "Provider_License_Number_State_Code_13" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_13" TEXT,
    "Healthcare_Provider_Taxonomy_Code_14" TEXT,
    "Provider_License_Number_14" TEXT,
    "Provider_License_Number_State_Code_14" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_14" TEXT,
    "Healthcare_Provider_Taxonomy_Code_15" TEXT,
    "Provider_License_Number_15" TEXT,
    "Provider_License_Number_State_Code_15" TEXT,
    "Healthcare_Provider_Primary_Taxonomy_Switch_15" TEXT,
    "Other_Provider_Identifier_1" TEXT,
    "Other_Provider_Identifier_Type_Code_1" TEXT,
    "Other_Provider_Identifier_State_1" TEXT,
    "Other_Provider_Identifier_Issuer_1" TEXT,
    "Other_Provider_Identifier_2" TEXT,
    "Other_Provider_Identifier_Type_Code_2" TEXT,
    "Other_Provider_Identifier_State_2" TEXT,
    "Other_Provider_Identifier_Issuer_2" TEXT,
    "Other_Provider_Identifier_3" TEXT,
    "Other_Provider_Identifier_Type_Code_3" TEXT,
    "Other_Provider_Identifier_State_3" TEXT,
    "Other_Provider_Identifier_Issuer_3" TEXT,
    "Other_Provider_Identifier_4" TEXT,
    "Other_Provider_Identifier_Type_Code_4" TEXT,
    "Other_Provider_Identifier_State_4" TEXT,
    "Other_Provider_Identifier_Issuer_4" TEXT,
    "Other_Provider_Identifier_5" TEXT,
    "Other_Provider_Identifier_Type_Code_5" TEXT,
    "Other_Provider_Identifier_State_5" TEXT,
    "Other_Provider_Identifier_Issuer_5" TEXT,
    "Other_Provider_Identifier_6" TEXT,
    "Other_Provider_Identifier_Type_Code_6" TEXT,
    "Other_Provider_Identifier_State_6" TEXT,
    "Other_Provider_Identifier_Issuer_6" TEXT,
    "Other_Provider_Identifier_7" TEXT,
    "Other_Provider_Identifier_Type_Code_7" TEXT,
    "Other_Provider_Identifier_State_7" TEXT,
    "Other_Provider_Identifier_Issuer_7" TEXT,
    "Other_Provider_Identifier_8" TEXT,
    "Other_Provider_Identifier_Type_Code_8" TEXT,
    "Other_Provider_Identifier_State_8" TEXT,
    "Other_Provider_Identifier_Issuer_8" TEXT,
    "Other_Provider_Identifier_9" TEXT,
    "Other_Provider_Identifier_Type_Code_9" TEXT,
    "Other_Provider_Identifier_State_9" TEXT,
    "Other_Provider_Identifier_Issuer_9" TEXT,
    "Other_Provider_Identifier_10" TEXT,
    "Other_Provider_Identifier_Type_Code_10" TEXT,
    "Other_Provider_Identifier_State_10" TEXT,
    "Other_Provider_Identifier_Issuer_10" TEXT,
    "Other_Provider_Identifier_11" TEXT,
    "Other_Provider_Identifier_Type_Code_11" TEXT,
    "Other_Provider_Identifier_State_11" TEXT,
    "Other_Provider_Identifier_Issuer_11" TEXT,
    "Other_Provider_Identifier_12" TEXT,
    "Other_Provider_Identifier_Type_Code_12" TEXT,
    "Other_Provider_Identifier_State_12" TEXT,
    "Other_Provider_Identifier_Issuer_12" TEXT,
    "Other_Provider_Identifier_13" TEXT,
    "Other_Provider_Identifier_Type_Code_13" TEXT,
    "Other_Provider_Identifier_State_13" TEXT,
    "Other_Provider_Identifier_Issuer_13" TEXT,
    "Other_Provider_Identifier_14" TEXT,
    "Other_Provider_Identifier_Type_Code_14" TEXT,
    "Other_Provider_Identifier_State_14" TEXT,
    "Other_Provider_Identifier_Issuer_14" TEXT,
    "Other_Provider_Identifier_15" TEXT,
    "Other_Provider_Identifier_Type_Code_15" TEXT,
    "Other_Provider_Identifier_State_15" TEXT,
    "Other_Provider_Identifier_Issuer_15" TEXT,
    "Other_Provider_Identifier_16" TEXT,
    "Other_Provider_Identifier_Type_Code_16" TEXT,
    "Other_Provider_Identifier_State_16" TEXT,
    "Other_Provider_Identifier_Issuer_16" TEXT,
    "Other_Provider_Identifier_17" TEXT,
    "Other_Provider_Identifier_Type_Code_17" TEXT,
    "Other_Provider_Identifier_State_17" TEXT,
    "Other_Provider_Identifier_Issuer_17" TEXT,
    "Other_Provider_Identifier_18" TEXT,
    "Other_Provider_Identifier_Type_Code_18" TEXT,
    "Other_Provider_Identifier_State_18" TEXT,
    "Other_Provider_Identifier_Issuer_18" TEXT,
    "Other_Provider_Identifier_19" TEXT,
    "Other_Provider_Identifier_Type_Code_19" TEXT,
    "Other_Provider_Identifier_State_19" TEXT,
    "Other_Provider_Identifier_Issuer_19" TEXT,
    "Other_Provider_Identifier_20" TEXT,
    "Other_Provider_Identifier_Type_Code_20" TEXT,
    "Other_Provider_Identifier_State_20" TEXT,
    "Other_Provider_Identifier_Issuer_20" TEXT,
    "Other_Provider_Identifier_21" TEXT,
    "Other_Provider_Identifier_Type_Code_21" TEXT,
    "Other_Provider_Identifier_State_21" TEXT,
    "Other_Provider_Identifier_Issuer_21" TEXT,
    "Other_Provider_Identifier_22" TEXT,
    "Other_Provider_Identifier_Type_Code_22" TEXT,
    "Other_Provider_Identifier_State_22" TEXT,
    "Other_Provider_Identifier_Issuer_22" TEXT,
    "Other_Provider_Identifier_23" TEXT,
    "Other_Provider_Identifier_Type_Code_23" TEXT,
    "Other_Provider_Identifier_State_23" TEXT,
    "Other_Provider_Identifier_Issuer_23" TEXT,
    "Other_Provider_Identifier_24" TEXT,
    "Other_Provider_Identifier_Type_Code_24" TEXT,
    "Other_Provider_Identifier_State_24" TEXT,
    "Other_Provider_Identifier_Issuer_24" TEXT,
    "Other_Provider_Identifier_25" TEXT,
    "Other_Provider_Identifier_Type_Code_25" TEXT,
    "Other_Provider_Identifier_State_25" TEXT,
    "Other_Provider_Identifier_Issuer_25" TEXT,
    "Other_Provider_Identifier_26" TEXT,
    "Other_Provider_Identifier_Type_Code_26" TEXT,
    "Other_Provider_Identifier_State_26" TEXT,
    "Other_Provider_Identifier_Issuer_26" TEXT,
    "Other_Provider_Identifier_27" TEXT,
    "Other_Provider_Identifier_Type_Code_27" TEXT,
    "Other_Provider_Identifier_State_27" TEXT,
    "Other_Provider_Identifier_Issuer_27" TEXT,
    "Other_Provider_Identifier_28" TEXT,
    "Other_Provider_Identifier_Type_Code_28" TEXT,
    "Other_Provider_Identifier_State_28" TEXT,
    "Other_Provider_Identifier_Issuer_28" TEXT,
    "Other_Provider_Identifier_29" TEXT,
    "Other_Provider_Identifier_Type_Code_29" TEXT,
    "Other_Provider_Identifier_State_29" TEXT,
    "Other_Provider_Identifier_Issuer_29" TEXT,
    "Other_Provider_Identifier_30" TEXT,
    "Other_Provider_Identifier_Type_Code_30" TEXT,
    "Other_Provider_Identifier_State_30" TEXT,
    "Other_Provider_Identifier_Issuer_30" TEXT,
    "Other_Provider_Identifier_31" TEXT,
    "Other_Provider_Identifier_Type_Code_31" TEXT,
    "Other_Provider_Identifier_State_31" TEXT,
    "Other_Provider_Identifier_Issuer_31" TEXT,
    "Other_Provider_Identifier_32" TEXT,
    "Other_Provider_Identifier_Type_Code_32" TEXT,
    "Other_Provider_Identifier_State_32" TEXT,
    "Other_Provider_Identifier_Issuer_32" TEXT,
    "Other_Provider_Identifier_33" TEXT,
    "Other_Provider_Identifier_Type_Code_33" TEXT,
    "Other_Provider_Identifier_State_33" TEXT,
    "Other_Provider_Identifier_Issuer_33" TEXT,
    "Other_Provider_Identifier_34" TEXT,
    "Other_Provider_Identifier_Type_Code_34" TEXT,
    "Other_Provider_Identifier_State_34" TEXT,
    "Other_Provider_Identifier_Issuer_34" TEXT,
    "Other_Provider_Identifier_35" TEXT,
    "Other_Provider_Identifier_Type_Code_35" TEXT,
    "Other_Provider_Identifier_State_35" TEXT,
    "Other_Provider_Identifier_Issuer_35" TEXT,
    "Other_Provider_Identifier_36" TEXT,
    "Other_Provider_Identifier_Type_Code_36" TEXT,
    "Other_Provider_Identifier_State_36" TEXT,
    "Other_Provider_Identifier_Issuer_36" TEXT,
    "Other_Provider_Identifier_37" TEXT,
    "Other_Provider_Identifier_Type_Code_37" TEXT,
    "Other_Provider_Identifier_State_37" TEXT,
    "Other_Provider_Identifier_Issuer_37" TEXT,
    "Other_Provider_Identifier_38" TEXT,
    "Other_Provider_Identifier_Type_Code_38" TEXT,
    "Other_Provider_Identifier_State_38" TEXT,
    "Other_Provider_Identifier_Issuer_38" TEXT,
    "Other_Provider_Identifier_39" TEXT,
    "Other_Provider_Identifier_Type_Code_39" TEXT,
    "Other_Provider_Identifier_State_39" TEXT,
    "Other_Provider_Identifier_Issuer_39" TEXT,
    "Other_Provider_Identifier_40" TEXT,
    "Other_Provider_Identifier_Type_Code_40" TEXT,
    "Other_Provider_Identifier_State_40" TEXT,
    "Other_Provider_Identifier_Issuer_40" TEXT,
    "Other_Provider_Identifier_41" TEXT,
    "Other_Provider_Identifier_Type_Code_41" TEXT,
    "Other_Provider_Identifier_State_41" TEXT,
    "Other_Provider_Identifier_Issuer_41" TEXT,
    "Other_Provider_Identifier_42" TEXT,
    "Other_Provider_Identifier_Type_Code_42" TEXT,
    "Other_Provider_Identifier_State_42" TEXT,
    "Other_Provider_Identifier_Issuer_42" TEXT,
    "Other_Provider_Identifier_43" TEXT,
    "Other_Provider_Identifier_Type_Code_43" TEXT,
    "Other_Provider_Identifier_State_43" TEXT,
    "Other_Provider_Identifier_Issuer_43" TEXT,
    "Other_Provider_Identifier_44" TEXT,
    "Other_Provider_Identifier_Type_Code_44" TEXT,
    "Other_Provider_Identifier_State_44" TEXT,
    "Other_Provider_Identifier_Issuer_44" TEXT,
    "Other_Provider_Identifier_45" TEXT,
    "Other_Provider_Identifier_Type_Code_45" TEXT,
    "Other_Provider_Identifier_State_45" TEXT,
    "Other_Provider_Identifier_Issuer_45" TEXT,
    "Other_Provider_Identifier_46" TEXT,
    "Other_Provider_Identifier_Type_Code_46" TEXT,
    "Other_Provider_Identifier_State_46" TEXT,
    "Other_Provider_Identifier_Issuer_46" TEXT,
    "Other_Provider_Identifier_47" TEXT,
    "Other_Provider_Identifier_Type_Code_47" TEXT,
    "Other_Provider_Identifier_State_47" TEXT,
    "Other_Provider_Identifier_Issuer_47" TEXT,
    "Other_Provider_Identifier_48" TEXT,
    "Other_Provider_Identifier_Type_Code_48" TEXT,
    "Other_Provider_Identifier_State_48" TEXT,
    "Other_Provider_Identifier_Issuer_48" TEXT,
    "Other_Provider_Identifier_49" TEXT,
    "Other_Provider_Identifier_Type_Code_49" TEXT,
    "Other_Provider_Identifier_State_49" TEXT,
    "Other_Provider_Identifier_Issuer_49" TEXT,
    "Other_Provider_Identifier_50" TEXT,
    "Other_Provider_Identifier_Type_Code_50" TEXT,
    "Other_Provider_Identifier_State_50" TEXT,
    "Other_Provider_Identifier_Issuer_50" TEXT,
    "Is_Sole_Proprietor" TEXT,
    "Is_Organization_Subpart" TEXT,
    "Parent_Organization_LBN" TEXT,
    "Parent_Organization_TIN" TEXT,
    "Authorized_Official_Name_Prefix_Text" TEXT,
    "Authorized_Official_Name_Suffix_Text" TEXT,
    "Authorized_Official_Credential_Text" TEXT,
    "Healthcare_Provider_Taxonomy_Group_1" TEXT,
    "Healthcare_Provider_Taxonomy_Group_2" TEXT,
    "Healthcare_Provider_Taxonomy_Group_3" TEXT,
    "Healthcare_Provider_Taxonomy_Group_4" TEXT,
    "Healthcare_Provider_Taxonomy_Group_5" TEXT,
    "Healthcare_Provider_Taxonomy_Group_6" TEXT,
    "Healthcare_Provider_Taxonomy_Group_7" TEXT,
    "Healthcare_Provider_Taxonomy_Group_8" TEXT,
    "Healthcare_Provider_Taxonomy_Group_9" TEXT,
    "Healthcare_Provider_Taxonomy_Group_10" TEXT,
    "Healthcare_Provider_Taxonomy_Group_11" TEXT,
    "Healthcare_Provider_Taxonomy_Group_12" TEXT,
    "Healthcare_Provider_Taxonomy_Group_13" TEXT,
    "Healthcare_Provider_Taxonomy_Group_14" TEXT,
    "Healthcare_Provider_Taxonomy_Group_15" TEXT,
    "Certification_Date" TEXT
);

DROP TABLE IF EXISTS staging_othername_pfile;

-- Create staging table to match CSV file
CREATE TABLE staging_othername_pfile (
    npi VARCHAR(10),
    provider_other_organization_name VARCHAR(255),
    provider_other_organization_name_type_code CHAR(1)
);

-- To import taxonomy_reference or any of the staging tables, use COPY or pgAdmin import wizard:
-- Example:
-- COPY taxonomy_reference (taxonomy_code, specialization, definition)
-- FROM '/path/to/nucc_taxonomy_cleaned.csv'
-- WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8', NULL '');
-- Example 2:
-- \COPY STAGING_TABLE_ENDPOINTS FROM '/path/to/endpoint_pfile.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
-- \COPY STAGING_TABLE_ENDPOINTS FROM '/home/rbrown/NPPES/Original_data/endpoint_pfile_20050523-20250608.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
