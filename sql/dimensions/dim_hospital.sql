--------------------------------------------------------------------------------
-->> Create Dimension Hospital Table
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.dim_hospital CASCADE;

CREATE TABLE public.dim_hospital (
    hospital_id                  VARCHAR(20) PRIMARY KEY,
    hospital_name                VARCHAR(150) NOT NULL,
    archetype                    VARCHAR(100),
    nhs_trust_type               VARCHAR(100),

    region_id                    VARCHAR(20),
    city                         VARCHAR(100),

    beds                         INTEGER,
    icu_beds                     INTEGER,
    ed_bays                      INTEGER,

    annual_budget_m              NUMERIC(12,2),
    staff_fte                    INTEGER,

    founding_year                INTEGER,
    teaching_hospital            BOOLEAN,
    trauma_level                 INTEGER,
    private_int                  BOOLEAN,

    avg_daily_admissions_base    INTEGER,
    satisfaction_base            INTEGER,

    efficiency_score             NUMERIC(5,2),
    cost_index                   NUMERIC(6,2),
    readmission_rate_base        NUMERIC(5,2),

    staffing_stress              VARCHAR(50),

    growth_trend                 NUMERIC(8,4),
    quality_trend                NUMERIC(8,4),

    special_profile              VARCHAR(255),

    latitude                     NUMERIC(10,6),
    longitude                    NUMERIC(10,6),

    total_beds                   INTEGER
);

--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Hospital Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_hospital (
    hospital_id                   VARCHAR(20) PRIMARY KEY,
    hospital_name                 VARCHAR(150) NOT NULL,
    archetype                     VARCHAR(100),
    nhs_trust_type                VARCHAR(100),
    
    region_id                     VARCHAR(20),
    city                          VARCHAR(100),

    beds                          INTEGER,
    icu_beds                      INTEGER,
    ed_bays                       INTEGER,
    total_beds                    INTEGER,

    annual_budget_m               NUMERIC(12,2),
    staff_fte                     INTEGER,

    founding_year                 INTEGER,
    teaching_hospital             BOOLEAN,
    trauma_level                  INTEGER,
    private_int                   BOOLEAN,

    avg_daily_admissions_base     INTEGER,
    satisfaction_base             NUMERIC(5,2),

    efficiency_score              NUMERIC(5,2),
    cost_index                    NUMERIC(6,2),
    readmission_rate_base         NUMERIC(5,2),

    staffing_stress               VARCHAR(50),

    growth_trend                  NUMERIC(5,2),
    quality_trend                 NUMERIC(5,2),

    special_profile               VARCHAR(255),

    latitude                      NUMERIC(10,6),
    longitude                     NUMERIC(10,6),

    created_at                    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_region
        FOREIGN KEY (region_id)
        REFERENCES bronze.dim_region(region_id),

    CONSTRAINT chk_beds
        CHECK (beds >= 0),

    CONSTRAINT chk_icu_beds
        CHECK (icu_beds >= 0),

    CONSTRAINT chk_ed_bays
        CHECK (ed_bays >= 0),

    CONSTRAINT chk_total_beds
        CHECK (total_beds >= 0),

    CONSTRAINT chk_budget
        CHECK (annual_budget_m >= 0),

    CONSTRAINT chk_staff
        CHECK (staff_fte >= 0),

    CONSTRAINT chk_trauma
        CHECK (trauma_level BETWEEN 1 AND 5),

    CONSTRAINT chk_satisfaction
        CHECK (satisfaction_base BETWEEN 0 AND 100),

    CONSTRAINT chk_efficiency
        CHECK (efficiency_score BETWEEN 0 AND 100),

    CONSTRAINT chk_readmission
        CHECK (readmission_rate_base BETWEEN 0 AND 100)
);