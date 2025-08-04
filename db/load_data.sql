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
FROM STAGING_TABLE_NPI;

-- ======================
-- Insert into provider_taxonomy (1-15)
-- ======================
INSERT INTO provider_taxonomy (
    provider_id, taxonomy_order, taxonomy_code, license_number, license_number_state_code, primary_taxonomy_switch, taxonomy_group
)
SELECT
    p.id,
    t.taxonomy_order,
    t.taxonomy_code,
    t.license_number,
    t.license_number_state_code,
    t.primary_taxonomy_switch,
    t.taxonomy_group
FROM (
    SELECT
        "NPI"::BIGINT AS npi,
        i AS taxonomy_order,
        tc AS taxonomy_code,
        lic AS license_number,
        lic_state AS license_number_state_code,
        switchval AS primary_taxonomy_switch,
        taxgroup AS taxonomy_group
    FROM STAGING_TABLE_NPI,
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
) t
JOIN providers p ON t.npi = p.npi
WHERE t.taxonomy_code IS NOT NULL AND t.taxonomy_code NOT IN ('', 'N/A');

-- ======================
-- Insert into provider_other_identifier (1-50)
-- ======================
INSERT INTO provider_other_identifier (
    provider_id, identifier_order, other_provider_identifier, type_code, state, issuer
)
SELECT
    p.id,
    t.identifier_order,
    t.other_provider_identifier,
    t.type_code,
    t.state,
    t.issuer
FROM (
    SELECT
        "NPI"::BIGINT AS npi,
        i AS identifier_order,
        id AS other_provider_identifier,
        type_code,
        state,
        issuer
    FROM STAGING_TABLE_NPI,
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
) t
JOIN providers p ON t.npi = p.npi
WHERE t.other_provider_identifier IS NOT NULL AND t.other_provider_identifier NOT IN ('', 'N/A');

-- ======================
-- Insert into provider_address (mailing)
-- ======================
INSERT INTO provider_address (
    provider_id, address_type, first_line, second_line, city, state, postal_code, country_code, telephone_number, fax_number
)
SELECT
    p.id,
    'mailing',
    s."Provider_First_Line_Business_Mailing_Address",
    s."Provider_Second_Line_Business_Mailing_Address",
    s."Provider_Business_Mailing_Address_City_Name",
    s."Provider_Business_Mailing_Address_State_Name",
    s."Provider_Business_Mailing_Address_Postal_Code",
    s."Provider_Business_Mailing_Address_Country_Code_If_outside_U_S_",
    s."Provider_Business_Mailing_Address_Telephone_Number",
    s."Provider_Business_Mailing_Address_Fax_Number"
FROM STAGING_TABLE_NPI s
JOIN providers p ON s."NPI" = p.npi
WHERE s."Provider_First_Line_Business_Mailing_Address" IS NOT NULL AND s."Provider_First_Line_Business_Mailing_Address" NOT IN ('', 'N/A');

-- ======================
-- Insert into provider_address (practice)
-- ======================
INSERT INTO provider_address (
    provider_id, address_type, first_line, second_line, city, state, postal_code, country_code, telephone_number, fax_number
)
SELECT
    p.id,
    'practice',
    s."Provider_First_Line_Business_Practice_Location_Address",
    s."Provider_Second_Line_Business_Practice_Location_Address",
    s."Provider_Business_Practice_Location_Address_City_Name",
    s."Provider_Business_Practice_Location_Address_State_Name",
    s."Provider_Business_Practice_Location_Address_Postal_Code",
    s."Provider_Business_Practice_Location_Address_Country_Code_If_outside_U_S_",
    s."Provider_Business_Practice_Location_Address_Telephone_Number",
    s."Provider_Business_Practice_Location_Address_Fax_Number"
FROM STAGING_TABLE_NPI s
JOIN providers p ON s."NPI" = p.npi
WHERE s."Provider_First_Line_Business_Practice_Location_Address" IS NOT NULL AND s."Provider_First_Line_Business_Practice_Location_Address" NOT IN ('', 'N/A');

-- ======================
-- Insert into provider_authorized_official
-- ======================
INSERT INTO provider_authorized_official (
    provider_id, npi, last_name, first_name, middle_name, title_or_position, telephone_number,
    name_prefix_text, name_suffix_text, credential_text
)
SELECT
    p.id,
    s."NPI",
    s."Authorized_Official_Last_Name",
    s."Authorized_Official_First_Name",
    s."Authorized_Official_Middle_Name",
    s."Authorized_Official_Title_or_Position",
    s."Authorized_Official_Telephone_Number",
    s."Authorized_Official_Name_Prefix_Text",
    s."Authorized_Official_Name_Suffix_Text",
    s."Authorized_Official_Credential_Text"
FROM STAGING_TABLE_NPI s
JOIN providers p ON s."NPI" = p.npi
WHERE s."Authorized_Official_Last_Name" IS NOT NULL AND s."Authorized_Official_Last_Name" NOT IN ('', 'N/A');

INSERT INTO ENDPOINT_AFFILIATION(
	AFFILIATION_PRIMARY_ADDRESS, 
	AFFILIATION_SECONDARY_ADDRESS, 
	AFFILIATION_ADDRESS_CITY,
	AFFILIATION_ADDRESS_STATE, 
	AFFILIATION_ADDRESS_COUNTRY,
	AFFILIATION_ADDRESS_POSTAL_CODE)
SELECT DISTINCT
    COALESCE(AFFILIATION_PRIMARY_ADDRESS, 'N/A'), 
    COALESCE(AFFILIATION_SECONDARY_ADDRESS, 'No Secondary Address'),
    COALESCE(AFFILIATION_ADDRESS_CITY, 'N/A'),
    COALESCE(AFFILIATION_ADDRESS_STATE, 'N/A'),
    COALESCE(AFFILIATION_ADDRESS_COUNTRY, 'XX'),
    COALESCE(AFFILIATION_ADDRESS_POSTAL_CODE, 'N/A')
FROM STAGING_TABLE_ENDPOINTS;

INSERT INTO ENDPOINTS(
    NPI,
    ENDPOINT_TYPE,
    ENDPOINT_TYPE_DESCRIPTION,
    ENDPOINT,
    AFFILIATION,
    AFFILIATION_ID,
    ENDPOINT_DESCRIPTION,
    BUSINESS_NAME,
    USE_CODE,
    USE_DESCRIPTION,
    OTHER_USE_DESCRIPTION,
    CONTENT_TYPE,
    CONTENT_DESCRIPTION,
    OTHER_CONTENT_DESCRIPTION
)
SELECT
    st.NPI,
    st.ENDPOINT_TYPE,
    COALESCE(st.ENDPOINT_TYPE_DESCRIPTION, 'N/A'),
    COALESCE(st.ENDPOINT, 'N/A'),
    COALESCE(st.AFFILIATION, 'X'),
    e.AFFILIATION_ID,
    COALESCE(st.ENDPOINT_DESCRIPTION, 'N/A'),
    COALESCE(st.BUSINESS_NAME, 'N/A'),
    COALESCE(st.USE_CODE, 'N/A'),
    COALESCE(st.USE_DESCRIPTION, 'N/A'),
    COALESCE(st.OTHER_CONTENT_DESCRIPTION, 'N/A'),
    COALESCE(st.CONTENT_TYPE, 'N/A'),
    COALESCE(st.CONTENT_DESCRIPTION, 'N/A'),
    COALESCE(st.OTHER_CONTENT_DESCRIPTION, 'N/A')
FROM STAGING_TABLE_ENDPOINTS st
JOIN ENDPOINT_AFFILIATION e ON 
COALESCE(st.AFFILIATION_PRIMARY_ADDRESS, 'N/A') = e.AFFILIATION_PRIMARY_ADDRESS AND 
COALESCE(st.AFFILIATION_SECONDARY_ADDRESS, 'No Secondary Address') = e.AFFILIATION_SECONDARY_ADDRESS AND
COALESCE(st.AFFILIATION_ADDRESS_CITY, 'N/A') = e.AFFILIATION_ADDRESS_CITY AND
COALESCE(st.AFFILIATION_ADDRESS_STATE, 'N/A') = e.AFFILIATION_ADDRESS_STATE AND
COALESCE(st.AFFILIATION_ADDRESS_COUNTRY, 'XX') = e.AFFILIATION_ADDRESS_COUNTRY AND
COALESCE(st.AFFILIATION_ADDRESS_POSTAL_CODE, 'N/A') = e.AFFILIATION_ADDRESS_POSTAL_CODE;

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

--# Drop all staging tables once finished.
DROP TABLE STAGING_TABLE_ENDPOINTS;
DROP TABLE STAGING_TABLE_NPI;
DROP TABLE STAGING_OTHERNAME_PFILE;
