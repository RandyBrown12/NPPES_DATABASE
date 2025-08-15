BEGIN;

CREATE TEMP TABLE temp_provider_taxonomies AS
SELECT
    "NPI"::BIGINT AS npi,
    i AS taxonomy_order,
    tc AS taxonomy_code,
    lic AS license_number,
    lic_state AS license_number_state_code,
    switchval AS primary_taxonomy_switch,
    taxgroup AS taxonomy_group
FROM STAGING_TABLE_NPI
CROSS JOIN LATERAL (VALUES
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
WHERE tc IS NOT NULL AND tc != '' AND tc != 'N/A';

INSERT INTO provider_taxonomy (
    provider_id, taxonomy_order, taxonomy_id, license_number, license_number_state_code, primary_taxonomy_switch, taxonomy_group
)
SELECT
    p.id,
    t.taxonomy_order,
    tr.id,
    t.license_number,
    t.license_number_state_code,
    t.primary_taxonomy_switch,
    t.taxonomy_group
FROM temp_provider_taxonomies t
JOIN providers p ON t.npi = p.npi
JOIN taxonomy_reference tr ON tr.taxonomy_code = t.taxonomy_code;

DROP TABLE IF EXISTS temp_provider_taxonomies;

COMMIT;