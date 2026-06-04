--------------------------------------------------------------------------------
-->> Create Dimension Doctor Table
--------------------------------------------------------------------------------

CREATE TABLE public.dim_doctor (
    doctor_id               VARCHAR(20) PRIMARY KEY,
    doctor_name             VARCHAR(150) NOT NULL,
    specialty               VARCHAR(100) NOT NULL,
    grade                   VARCHAR(50),

    years_experience        INTEGER,
    primary_hospital_id     VARCHAR(20) NOT NULL,
    annual_salary           NUMERIC(12,2),
    part_time_flag          BOOLEAN,
    burnout_baseline        NUMERIC(5,2)
);

--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Doctor Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_doctor (
    doctor_id               VARCHAR(20) PRIMARY KEY,
    doctor_name             VARCHAR(150) NOT NULL,
    specialty               VARCHAR(100) NOT NULL,
    grade                   VARCHAR(50),

    years_experience        INTEGER CHECK (years_experience >= 0),

    primary_hospital_id     VARCHAR(20) NOT NULL,

    annual_salary           NUMERIC(12,2) CHECK (annual_salary >= 0),

    part_time_flag          BOOLEAN,

    burnout_baseline        NUMERIC(5,2)
        CHECK (burnout_baseline BETWEEN 0 AND 100),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_doctor_hospital
        FOREIGN KEY (primary_hospital_id)
        REFERENCES bronze.dim_hospital(hospital_id)
);
