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
JOIN providers p ON s."NPI" = p.NPI
WHERE s."Authorized_Official_Last_Name" IS NOT NULL AND s."Authorized_Official_Last_Name" NOT IN ('', 'N/A');