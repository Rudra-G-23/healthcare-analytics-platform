--------------------------------------------------------------------------------
-->> Create Fact Staffing Table
--------------------------------------------------------------------------------

CREATE TABLE public.fact_staffing (
    shift_id                 VARCHAR(30) PRIMARY KEY,
    hospital_id              VARCHAR(20) NOT NULL,
    department_id            VARCHAR(20) NOT NULL,
    shift_date               DATE NOT NULL,

    shift_type               VARCHAR(20),
    doctors_on_duty          INTEGER,
    nurses_on_duty           INTEGER,

    support_staff_count      INTEGER,

    staff_absence_count      INTEGER,

    overtime_hours           NUMERIC(10,2),
    staff_cost               NUMERIC(12,2),
    burnout_risk_index       NUMERIC(5,2),
    month_name                    INTEGER,

    hospital_name            VARCHAR(150),
    latitude                 NUMERIC(10,6),
    longitude                NUMERIC(10,6),
);

--------------------------------------------------------------------------------
-->> Create Production Grade Fact Staffing Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.fact_staffing (
    shift_id                 VARCHAR(30) PRIMARY KEY,

    hospital_id              VARCHAR(20) NOT NULL,

    department_id            VARCHAR(20) NOT NULL,

    shift_date               DATE NOT NULL,

    shift_type               VARCHAR(20),

    doctors_on_duty          INTEGER
        CHECK (doctors_on_duty >= 0),

    nurses_on_duty           INTEGER
        CHECK (nurses_on_duty >= 0),

    support_staff_count      INTEGER
        CHECK (support_staff_count >= 0),

    staff_absence_count      INTEGER
        CHECK (staff_absence_count >= 0),

    overtime_hours           NUMERIC(10,2)
        CHECK (overtime_hours >= 0),

    staff_cost               NUMERIC(12,2)
        CHECK (staff_cost >= 0),

    burnout_risk_index       NUMERIC(5,2)
        CHECK (burnout_risk_index BETWEEN 0 AND 100),

    month_name                    INTEGER
        CHECK (month_name BETWEEN 1 AND 12),

    hospital_name            VARCHAR(150),

    latitude                 NUMERIC(10,6),

    longitude                NUMERIC(10,6),

    created_at               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_staffing_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES bronze.dim_hospital(hospital_id),

    CONSTRAINT fk_staffing_department
        FOREIGN KEY (department_id)
        REFERENCES bronze.dim_department(department_id),

    CONSTRAINT chk_shift_type
        CHECK (
            shift_type IN (
                'Morning',
                'Evening',
                'Night'
            )
        )
);