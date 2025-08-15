-- This needs to be run first due to provider_taxonomy depending on it
CREATE TABLE IF NOT EXISTS taxonomy_reference (
    id BIGSERIAL PRIMARY KEY,
    taxonomy_code VARCHAR(20) UNIQUE NOT NULL,
    specialization VARCHAR(255) NOT NULL,
    definition TEXT NOT NULL,
    CREATED_AT TIMESTAMPTZ NOT NULL DEFAULT now(),
    UPDATED_AT TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_taxonomy_reference_taxonomy_code ON taxonomy_reference(taxonomy_code);