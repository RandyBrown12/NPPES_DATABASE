
-- 1. Providers table (npi as PK)
CREATE TABLE providers (
    npi BIGINT PRIMARY KEY,
    entity_type_code VARCHAR(2),
    replacement_npi BIGINT,
    employer_identification_number VARCHAR(20),
    provider_organization_name VARCHAR(200),
    provider_last_name VARCHAR(100),
    provider_first_name VARCHAR(100),
    provider_middle_name VARCHAR(100),
    provider_name_prefix_text VARCHAR(20),
    provider_name_suffix_text VARCHAR(20),
    provider_credential_text VARCHAR(50),
    provider_other_organization_name VARCHAR(200),
    provider_other_organization_name_type_code VARCHAR(2),
    provider_other_last_name VARCHAR(100),
    provider_other_first_name VARCHAR(100),
    provider_other_middle_name VARCHAR(100),
    provider_other_name_prefix_text VARCHAR(20),
    provider_other_name_suffix_text VARCHAR(20),
    provider_other_credential_text VARCHAR(50),
    provider_other_last_name_type_code VARCHAR(2),
    provider_enumeration_date DATE,
    last_update_date DATE,
    npi_deactivation_reason_code VARCHAR(2),
    npi_deactivation_date DATE,
    npi_reactivation_date DATE,
    provider_sex_code VARCHAR(1),
    is_sole_proprietor YES_OR_NO,
    is_organization_subpart YES_OR_NO,
    parent_organization_lbn VARCHAR(200),
    parent_organization_tin VARCHAR(20),
    certification_date DATE
);

-- 2. provider_taxonomy table 
CREATE TABLE provider_taxonomy (
    id SERIAL PRIMARY KEY,
    npi BIGINT REFERENCES providers(npi),
    taxonomy_order INT, -- 1 to 15, corresponds to _1..._15
    taxonomy_code VARCHAR(20),
    license_number VARCHAR(50),
    license_number_state_code VARCHAR(5),
    primary_taxonomy_switch VARCHAR(1),
    taxonomy_group VARCHAR(100)
);

-- 3. provider_address table 
CREATE TABLE provider_address (
    id SERIAL PRIMARY KEY,
    npi BIGINT REFERENCES providers(npi),
    address_type VARCHAR(30), -- e.g., 'mailing', 'practice'
    first_line VARCHAR(200),
    second_line VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country_code VARCHAR(5),
    telephone_number VARCHAR(20),
    fax_number VARCHAR(20)
);

-- 4. provider_other_identifier table 
CREATE TABLE provider_other_identifier (
    id SERIAL PRIMARY KEY,
    npi BIGINT REFERENCES providers(npi),
    identifier_order INT, -- 1 to 50, corresponds to _1..._50
    other_provider_identifier VARCHAR(1000),
    type_code VARCHAR(10),
    state VARCHAR(5),
    issuer VARCHAR(200)
);

-- 5. provider_authorized_official (npi as PK)
CREATE TABLE provider_authorized_official (
    npi BIGINT PRIMARY KEY,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    title_or_position VARCHAR(100),
    telephone_number VARCHAR(20),
    name_prefix_text VARCHAR(20),
    name_suffix_text VARCHAR(20),
    credential_text VARCHAR(50),
    FOREIGN KEY (npi) REFERENCES providers(npi)
);

-- 6. taxonomy_reference (taxonomy_code as PK)
CREATE TABLE taxonomy_reference (
    taxonomy_code VARCHAR(20) PRIMARY KEY,
    specialization VARCHAR(255),
    definition TEXT
);


-- Providers
INSERT INTO providers (
    npi, entity_type_code, replacement_npi, employer_identification_number,
    provider_organization_name, provider_last_name, provider_first_name, provider_middle_name,
    provider_name_prefix_text, provider_name_suffix_text, provider_credential_text,
    provider_other_organization_name, provider_other_organization_name_type_code,
    provider_other_last_name, provider_other_first_name, provider_other_middle_name,
    provider_other_name_prefix_text, provider_other_name_suffix_text, provider_other_credential_text,
    provider_other_last_name_type_code, provider_enumeration_date, last_update_date,
    npi_deactivation_reason_code, npi_deactivation_date, npi_reactivation_date,
    provider_sex_code, is_sole_proprietor, is_organization_subpart, parent_organization_lbn,
    parent_organization_tin, certification_date
)
SELECT
    CASE WHEN "NPI" IN ('', 'N/A') THEN NULL ELSE "NPI"::BIGINT END,
    "Entity_Type_Code",
    CASE WHEN "Replacement_NPI" IN ('', 'N/A') THEN NULL ELSE "Replacement_NPI"::BIGINT END,
    "Employer_Identification_Number_EIN",
    "Provider_Organization_Name_Legal_Business_Name", "Provider_Last_Name_Legal_Name", "Provider_First_Name", "Provider_Middle_Name",
    "Provider_Name_Prefix_Text", "Provider_Name_Suffix_Text", "Provider_Credential_Text",
    "Provider_Other_Organization_Name", "Provider_Other_Organization_Name_Type_Code",
    "Provider_Other_Last_Name", "Provider_Other_First_Name", "Provider_Other_Middle_Name",
    "Provider_Other_Name_Prefix_Text", "Provider_Other_Name_Suffix_Text", "Provider_Other_Credential_Text",
    "Provider_Other_Last_Name_Type_Code",
    CASE WHEN "Provider_Enumeration_Date" IN ('', 'N/A') THEN NULL ELSE TO_DATE("Provider_Enumeration_Date", 'MM/DD/YYYY') END,
    CASE WHEN "Last_Update_Date" IN ('', 'N/A') THEN NULL ELSE TO_DATE("Last_Update_Date", 'MM/DD/YYYY') END,
    "NPI_Deactivation_Reason_Code",
    CASE WHEN "NPI_Deactivation_Date" IN ('', 'N/A') THEN NULL ELSE TO_DATE("NPI_Deactivation_Date", 'MM/DD/YYYY') END,
    CASE WHEN "NPI_Reactivation_Date" IN ('', 'N/A') THEN NULL ELSE TO_DATE("NPI_Reactivation_Date", 'MM/DD/YYYY') END,
    CASE WHEN "Provider_Sex_Code" IN ('', 'N/A') THEN NULL ELSE LEFT("Provider_Sex_Code", 1) END,
    CASE WHEN TRIM("Is_Sole_Proprietor") IN ('', 'N/A', 'X', ' ') THEN NULL ELSE "Is_Sole_Proprietor"::YES_OR_NO END,
    CASE WHEN TRIM("Is_Organization_Subpart") IN ('', 'N/A', 'X', ' ') THEN NULL ELSE "Is_Organization_Subpart"::YES_OR_NO END,
    "Parent_Organization_LBN", "Parent_Organization_TIN",
    CASE WHEN "Certification_Date" IN ('', 'N/A') THEN NULL ELSE TO_DATE("Certification_Date", 'MM/DD/YYYY') END
FROM npi_staging;


INSERT INTO provider_taxonomy (
    npi, taxonomy_order, taxonomy_code, license_number, license_number_state_code, primary_taxonomy_switch, taxonomy_group
)
SELECT * FROM (
    SELECT
        CASE WHEN "NPI" IN ('', 'N/A') THEN NULL ELSE "NPI"::BIGINT END,
        i AS taxonomy_order,
        CASE WHEN tc = 'N/A' THEN NULL ELSE tc END AS taxonomy_code,
        lic,
        lic_state,
        CASE WHEN TRIM(switchval) IN ('', 'N/A', 'X', ' ') THEN NULL ELSE switchval::YES_OR_NO END,
        taxgroup
    FROM npi_staging,
    LATERAL (VALUES
        (1, "Healthcare_Provider_Taxonomy_Code_1", "Provider_License_Number_1", "Provider_License_Number_State_Code_1", "Healthcare_Provider_Primary_Taxonomy_Switch_1", "Healthcare_Provider_Taxonomy_Group_1"),
        (2, "Healthcare_Provider_Taxonomy_Code_2", "Provider_License_Number_2", "Provider_License_Number_State_Code_2", "Healthcare_Provider_Primary_Taxonomy_Switch_2", "Healthcare_Provider_Taxonomy_Group_2"),
        (3, "Healthcare_Provider_Taxonomy_Code_3", "Provider_License_Number_3", "Provider_License_Number_State_Code_3", "Healthcare_Provider_Primary_Taxonomy_Switch_3", "Healthcare_Provider_Taxonomy_Group_3"),
        (4, "Healthcare_Provider_Taxonomy_Code_4", "Provider_License_Number_4", "Provider_License_Number_State_Code_4", "Healthcare_Provider_Primary_Taxonomy_Switch_4", "Healthcare_Provider_Taxonomy_Group_4"),
        (5, "Healthcare_Provider_Taxonomy_Code_5", "Provider_License_Number_5", "Provider_License_Number_State_Code_5", "Healthcare_Provider_Primary_Taxonomy_Switch_5", "Healthcare_Provider_Taxonomy_Group_5"),
        (6, "Healthcare_Provider_Taxonomy_Code_6", "Provider_License_Number_6", "Provider_License_Number_State_Code_6", "Healthcare_Provider_Primary_Taxonomy_Switch_6", "Healthcare_Provider_Taxonomy_Group_6"),
        (7, "Healthcare_Provider_Taxonomy_Code_7", "Provider_License_Number_7", "Provider_License_Number_State_Code_7", "Healthcare_Provider_Primary_Taxonomy_Switch_7", "Healthcare_Provider_Taxonomy_Group_7"),
        (8, "Healthcare_Provider_Taxonomy_Code_8", "Provider_License_Number_8", "Provider_License_Number_State_Code_8", "Healthcare_Provider_Primary_Taxonomy_Switch_8", "Healthcare_Provider_Taxonomy_Group_8"),
        (9, "Healthcare_Provider_Taxonomy_Code_9", "Provider_License_Number_9", "Provider_License_Number_State_Code_9", "Healthcare_Provider_Primary_Taxonomy_Switch_9", "Healthcare_Provider_Taxonomy_Group_9"),
        (10, "Healthcare_Provider_Taxonomy_Code_10", "Provider_License_Number_10", "Provider_License_Number_State_Code_10", "Healthcare_Provider_Primary_Taxonomy_Switch_10", "Healthcare_Provider_Taxonomy_Group_10"),
        (11, "Healthcare_Provider_Taxonomy_Code_11", "Provider_License_Number_11", "Provider_License_Number_State_Code_11", "Healthcare_Provider_Primary_Taxonomy_Switch_11", "Healthcare_Provider_Taxonomy_Group_11"),
        (12, "Healthcare_Provider_Taxonomy_Code_12", "Provider_License_Number_12", "Provider_License_Number_State_Code_12", "Healthcare_Provider_Primary_Taxonomy_Switch_12", "Healthcare_Provider_Taxonomy_Group_12"),
        (13, "Healthcare_Provider_Taxonomy_Code_13", "Provider_License_Number_13", "Provider_License_Number_State_Code_13", "Healthcare_Provider_Primary_Taxonomy_Switch_13", "Healthcare_Provider_Taxonomy_Group_13"),
        (14, "Healthcare_Provider_Taxonomy_Code_14", "Provider_License_Number_14", "Provider_License_Number_State_Code_14", "Healthcare_Provider_Primary_Taxonomy_Switch_14", "Healthcare_Provider_Taxonomy_Group_14"),
        (15, "Healthcare_Provider_Taxonomy_Code_15", "Provider_License_Number_15", "Provider_License_Number_State_Code_15", "Healthcare_Provider_Primary_Taxonomy_Switch_15", "Healthcare_Provider_Taxonomy_Group_15")
    ) AS vals(i, tc, lic, lic_state, switchval, taxgroup)
) AS all_rows
WHERE taxonomy_code IS NOT NULL AND taxonomy_code NOT IN ('', 'N/A');


INSERT INTO provider_other_identifier (
    npi, identifier_order, other_provider_identifier, type_code, state, issuer
)
SELECT * FROM (
    SELECT
        CASE WHEN "NPI" IN ('', 'N/A') THEN NULL ELSE "NPI"::BIGINT END,
        i AS identifier_order,
        CASE WHEN id = 'N/A' THEN NULL ELSE id END AS other_provider_identifier,
        type_code,
        state,
        issuer
    FROM npi_staging,
    LATERAL (VALUES
        (1, "Other_Provider_Identifier_1", "Other_Provider_Identifier_Type_Code_1", "Other_Provider_Identifier_State_1", "Other_Provider_Identifier_Issuer_1"),
        (2, "Other_Provider_Identifier_2", "Other_Provider_Identifier_Type_Code_2", "Other_Provider_Identifier_State_2", "Other_Provider_Identifier_Issuer_2"),
        (3, "Other_Provider_Identifier_3", "Other_Provider_Identifier_Type_Code_3", "Other_Provider_Identifier_State_3", "Other_Provider_Identifier_Issuer_3"),
        (4, "Other_Provider_Identifier_4", "Other_Provider_Identifier_Type_Code_4", "Other_Provider_Identifier_State_4", "Other_Provider_Identifier_Issuer_4"),
        (5, "Other_Provider_Identifier_5", "Other_Provider_Identifier_Type_Code_5", "Other_Provider_Identifier_State_5", "Other_Provider_Identifier_Issuer_5"),
        (6, "Other_Provider_Identifier_6", "Other_Provider_Identifier_Type_Code_6", "Other_Provider_Identifier_State_6", "Other_Provider_Identifier_Issuer_6"),
        (7, "Other_Provider_Identifier_7", "Other_Provider_Identifier_Type_Code_7", "Other_Provider_Identifier_State_7", "Other_Provider_Identifier_Issuer_7"),
        (8, "Other_Provider_Identifier_8", "Other_Provider_Identifier_Type_Code_8", "Other_Provider_Identifier_State_8", "Other_Provider_Identifier_Issuer_8"),
        (9, "Other_Provider_Identifier_9", "Other_Provider_Identifier_Type_Code_9", "Other_Provider_Identifier_State_9", "Other_Provider_Identifier_Issuer_9"),
        (10, "Other_Provider_Identifier_10", "Other_Provider_Identifier_Type_Code_10", "Other_Provider_Identifier_State_10", "Other_Provider_Identifier_Issuer_10"),
        (11, "Other_Provider_Identifier_11", "Other_Provider_Identifier_Type_Code_11", "Other_Provider_Identifier_State_11", "Other_Provider_Identifier_Issuer_11"),
        (12, "Other_Provider_Identifier_12", "Other_Provider_Identifier_Type_Code_12", "Other_Provider_Identifier_State_12", "Other_Provider_Identifier_Issuer_12"),
        (13, "Other_Provider_Identifier_13", "Other_Provider_Identifier_Type_Code_13", "Other_Provider_Identifier_State_13", "Other_Provider_Identifier_Issuer_13"),
        (14, "Other_Provider_Identifier_14", "Other_Provider_Identifier_Type_Code_14", "Other_Provider_Identifier_State_14", "Other_Provider_Identifier_Issuer_14"),
        (15, "Other_Provider_Identifier_15", "Other_Provider_Identifier_Type_Code_15", "Other_Provider_Identifier_State_15", "Other_Provider_Identifier_Issuer_15"),
        (16, "Other_Provider_Identifier_16", "Other_Provider_Identifier_Type_Code_16", "Other_Provider_Identifier_State_16", "Other_Provider_Identifier_Issuer_16"),
        (17, "Other_Provider_Identifier_17", "Other_Provider_Identifier_Type_Code_17", "Other_Provider_Identifier_State_17", "Other_Provider_Identifier_Issuer_17"),
        (18, "Other_Provider_Identifier_18", "Other_Provider_Identifier_Type_Code_18", "Other_Provider_Identifier_State_18", "Other_Provider_Identifier_Issuer_18"),
        (19, "Other_Provider_Identifier_19", "Other_Provider_Identifier_Type_Code_19", "Other_Provider_Identifier_State_19", "Other_Provider_Identifier_Issuer_19"),
        (20, "Other_Provider_Identifier_20", "Other_Provider_Identifier_Type_Code_20", "Other_Provider_Identifier_State_20", "Other_Provider_Identifier_Issuer_20"),
        (21, "Other_Provider_Identifier_21", "Other_Provider_Identifier_Type_Code_21", "Other_Provider_Identifier_State_21", "Other_Provider_Identifier_Issuer_21"),
        (22, "Other_Provider_Identifier_22", "Other_Provider_Identifier_Type_Code_22", "Other_Provider_Identifier_State_22", "Other_Provider_Identifier_Issuer_22"),
        (23, "Other_Provider_Identifier_23", "Other_Provider_Identifier_Type_Code_23", "Other_Provider_Identifier_State_23", "Other_Provider_Identifier_Issuer_23"),
        (24, "Other_Provider_Identifier_24", "Other_Provider_Identifier_Type_Code_24", "Other_Provider_Identifier_State_24", "Other_Provider_Identifier_Issuer_24"),
        (25, "Other_Provider_Identifier_25", "Other_Provider_Identifier_Type_Code_25", "Other_Provider_Identifier_State_25", "Other_Provider_Identifier_Issuer_25"),
        (26, "Other_Provider_Identifier_26", "Other_Provider_Identifier_Type_Code_26", "Other_Provider_Identifier_State_26", "Other_Provider_Identifier_Issuer_26"),
        (27, "Other_Provider_Identifier_27", "Other_Provider_Identifier_Type_Code_27", "Other_Provider_Identifier_State_27", "Other_Provider_Identifier_Issuer_27"),
        (28, "Other_Provider_Identifier_28", "Other_Provider_Identifier_Type_Code_28", "Other_Provider_Identifier_State_28", "Other_Provider_Identifier_Issuer_28"),
        (29, "Other_Provider_Identifier_29", "Other_Provider_Identifier_Type_Code_29", "Other_Provider_Identifier_State_29", "Other_Provider_Identifier_Issuer_29"),
        (30, "Other_Provider_Identifier_30", "Other_Provider_Identifier_Type_Code_30", "Other_Provider_Identifier_State_30", "Other_Provider_Identifier_Issuer_30"),
        (31, "Other_Provider_Identifier_31", "Other_Provider_Identifier_Type_Code_31", "Other_Provider_Identifier_State_31", "Other_Provider_Identifier_Issuer_31"),
        (32, "Other_Provider_Identifier_32", "Other_Provider_Identifier_Type_Code_32", "Other_Provider_Identifier_State_32", "Other_Provider_Identifier_Issuer_32"),
        (33, "Other_Provider_Identifier_33", "Other_Provider_Identifier_Type_Code_33", "Other_Provider_Identifier_State_33", "Other_Provider_Identifier_Issuer_33"),
        (34, "Other_Provider_Identifier_34", "Other_Provider_Identifier_Type_Code_34", "Other_Provider_Identifier_State_34", "Other_Provider_Identifier_Issuer_34"),
        (35, "Other_Provider_Identifier_35", "Other_Provider_Identifier_Type_Code_35", "Other_Provider_Identifier_State_35", "Other_Provider_Identifier_Issuer_35"),
        (36, "Other_Provider_Identifier_36", "Other_Provider_Identifier_Type_Code_36", "Other_Provider_Identifier_State_36", "Other_Provider_Identifier_Issuer_36"),
        (37, "Other_Provider_Identifier_37", "Other_Provider_Identifier_Type_Code_37", "Other_Provider_Identifier_State_37", "Other_Provider_Identifier_Issuer_37"),
        (38, "Other_Provider_Identifier_38", "Other_Provider_Identifier_Type_Code_38", "Other_Provider_Identifier_State_38", "Other_Provider_Identifier_Issuer_38"),
        (39, "Other_Provider_Identifier_39", "Other_Provider_Identifier_Type_Code_39", "Other_Provider_Identifier_State_39", "Other_Provider_Identifier_Issuer_39"),
        (40, "Other_Provider_Identifier_40", "Other_Provider_Identifier_Type_Code_40", "Other_Provider_Identifier_State_40", "Other_Provider_Identifier_Issuer_40"),
        (41, "Other_Provider_Identifier_41", "Other_Provider_Identifier_Type_Code_41", "Other_Provider_Identifier_State_41", "Other_Provider_Identifier_Issuer_41"),
        (42, "Other_Provider_Identifier_42", "Other_Provider_Identifier_Type_Code_42", "Other_Provider_Identifier_State_42", "Other_Provider_Identifier_Issuer_42"),
        (43, "Other_Provider_Identifier_43", "Other_Provider_Identifier_Type_Code_43", "Other_Provider_Identifier_State_43", "Other_Provider_Identifier_Issuer_43"),
        (44, "Other_Provider_Identifier_44", "Other_Provider_Identifier_Type_Code_44", "Other_Provider_Identifier_State_44", "Other_Provider_Identifier_Issuer_44"),
        (45, "Other_Provider_Identifier_45", "Other_Provider_Identifier_Type_Code_45", "Other_Provider_Identifier_State_45", "Other_Provider_Identifier_Issuer_45"),
        (46, "Other_Provider_Identifier_46", "Other_Provider_Identifier_Type_Code_46", "Other_Provider_Identifier_State_46", "Other_Provider_Identifier_Issuer_46"),
        (47, "Other_Provider_Identifier_47", "Other_Provider_Identifier_Type_Code_47", "Other_Provider_Identifier_State_47", "Other_Provider_Identifier_Issuer_47"),
        (48, "Other_Provider_Identifier_48", "Other_Provider_Identifier_Type_Code_48", "Other_Provider_Identifier_State_48", "Other_Provider_Identifier_Issuer_48"),
        (49, "Other_Provider_Identifier_49", "Other_Provider_Identifier_Type_Code_49", "Other_Provider_Identifier_State_49", "Other_Provider_Identifier_Issuer_49"),
        (50, "Other_Provider_Identifier_50", "Other_Provider_Identifier_Type_Code_50", "Other_Provider_Identifier_State_50", "Other_Provider_Identifier_Issuer_50")
    ) AS vals(i, id, type_code, state, issuer)
) AS all_rows
WHERE other_provider_identifier IS NOT NULL AND other_provider_identifier NOT IN ('', 'N/A');


-- Mailing Address
INSERT INTO provider_address (
    npi, address_type, first_line, second_line, city, state, postal_code, country_code, telephone_number, fax_number
)
SELECT
    CASE WHEN "NPI" IN ('', 'N/A') THEN NULL ELSE "NPI"::BIGINT END,
    'mailing',
    "Provider_First_Line_Business_Mailing_Address",
    "Provider_Second_Line_Business_Mailing_Address",
    "Provider_Business_Mailing_Address_City_Name",
    "Provider_Business_Mailing_Address_State_Name",
    "Provider_Business_Mailing_Address_Postal_Code",
    "Provider_Business_Mailing_Address_Country_Code_If_outside_U_S_",
    "Provider_Business_Mailing_Address_Telephone_Number",
    "Provider_Business_Mailing_Address_Fax_Number"
FROM npi_staging
WHERE "Provider_First_Line_Business_Mailing_Address" IS NOT NULL AND "Provider_First_Line_Business_Mailing_Address" NOT IN ('', 'N/A');

-- Practice Address
INSERT INTO provider_address (
    npi, address_type, first_line, second_line, city, state, postal_code, country_code, telephone_number, fax_number
)
SELECT
    CASE WHEN "NPI" IN ('', 'N/A') THEN NULL ELSE "NPI"::BIGINT END,
    'practice',
    "Provider_First_Line_Business_Practice_Location_Address",
    "Provider_Second_Line_Business_Practice_Location_Address",
    "Provider_Business_Practice_Location_Address_City_Name",
    "Provider_Business_Practice_Location_Address_State_Name",
    "Provider_Business_Practice_Location_Address_Postal_Code",
    "Provider_Business_Practice_Location_Address_Country_Code_If_outside_U_S_",
    "Provider_Business_Practice_Location_Address_Telephone_Number",
    "Provider_Business_Practice_Location_Address_Fax_Number"
FROM npi_staging
WHERE "Provider_First_Line_Business_Practice_Location_Address" IS NOT NULL AND "Provider_First_Line_Business_Practice_Location_Address" NOT IN ('', 'N/A');


INSERT INTO provider_authorized_official (
    npi, last_name, first_name, middle_name, title_or_position, telephone_number,
    name_prefix_text, name_suffix_text, credential_text
)
SELECT
    CASE WHEN "NPI" IN ('', 'N/A') THEN NULL ELSE "NPI"::BIGINT END,
    "Authorized_Official_Last_Name",
    "Authorized_Official_First_Name",
    "Authorized_Official_Middle_Name",
    "Authorized_Official_Title_or_Position",
    "Authorized_Official_Telephone_Number",
    "Authorized_Official_Name_Prefix_Text",
    "Authorized_Official_Name_Suffix_Text",
    "Authorized_Official_Credential_Text"
FROM npi_staging
WHERE "Authorized_Official_Last_Name" IS NOT NULL AND "Authorized_Official_Last_Name" NOT IN ('', 'N/A');


-- To import taxonomy_reference table, use COPY or pgAdmin import wizard:
-- Example:
-- COPY taxonomy_reference (taxonomy_code, specialization, definition)
-- FROM '/path/to/nucc_taxonomy_cleaned.csv'
-- WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');