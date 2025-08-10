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
JOIN providers p ON s."NPI" = p.NPI
WHERE s."Provider_First_Line_Business_Mailing_Address" IS NOT NULL AND s."Provider_First_Line_Business_Mailing_Address" NOT IN ('', 'N/A');