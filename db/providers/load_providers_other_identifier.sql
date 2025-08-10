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
JOIN providers p ON t.NPI = p.NPI
WHERE t.other_provider_identifier IS NOT NULL AND t.other_provider_identifier NOT IN ('', 'N/A');