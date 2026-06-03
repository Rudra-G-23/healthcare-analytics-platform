--------------------------------------------------------------------------------
-->> Create Dimension Diagnosis Table
--------------------------------------------------------------------------------

CREATE TABLE public.dim_diagnosis (
    diagnosis_id         VARCHAR(20) PRIMARY KEY,
    category             VARCHAR(100) NOT NULL,
    icd_chapter          VARCHAR(100) NOT NULL,
    severity_weight      NUMERIC(5,2),
    icu_probability      NUMERIC(5,2),
    avg_los_hours        INTEGER,
    readmission_risk     VARCHAR(20),
    cost_weight          NUMERIC(6,2),

    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Diagnosis Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_diagnosis (
    diagnosis_id         VARCHAR(20) PRIMARY KEY,

    category             VARCHAR(100) NOT NULL,

    icd_chapter          VARCHAR(100) NOT NULL,

    severity_weight      NUMERIC(5,2)
        CHECK (severity_weight >= 0),

    icu_probability      NUMERIC(5,2)
        CHECK (icu_probability BETWEEN 0 AND 100),

    avg_los_hours        INTEGER
        CHECK (avg_los_hours >= 0),

    readmission_risk     VARCHAR(20),

    cost_weight          NUMERIC(6,2)
        CHECK (cost_weight >= 0),

    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_readmission_risk
        CHECK (
            readmission_risk IN (
                'Low',
                'Medium',
                'High',
                'Critical'
            )
        )
);