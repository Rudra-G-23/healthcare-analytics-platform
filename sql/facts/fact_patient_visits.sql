--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Fact Patient Table
--------------------------------------------------------------------------------
CREATE TABLE bronze.fact_patient_visits (
    visit_id                     VARCHAR(30) PRIMARY KEY,

    patient_id                   VARCHAR(20) NOT NULL,
    hospital_id                  VARCHAR(20) NOT NULL,
    department_id                VARCHAR(20) NOT NULL,
    doctor_id                    VARCHAR(20) NOT NULL,

    arrival_datetime             TIMESTAMP NOT NULL,
    triage_datetime              TIMESTAMP,
    treatment_start_datetime     TIMESTAMP,
    discharge_datetime           TIMESTAMP,

    admission_type               VARCHAR(50),

    severity_level               INTEGER
        CHECK (severity_level BETWEEN 1 AND 5),

    diagnosis_category           VARCHAR(100),

    length_of_stay_hours         NUMERIC(10,2)
        CHECK (length_of_stay_hours >= 0),

    wait_time_minutes            NUMERIC(10,2)
        CHECK (wait_time_minutes >= 0),

    treatment_delay_minutes      INTEGER
        CHECK (treatment_delay_minutes >= 0),

    icu_required_flag            BOOLEAN,

    outcome                      VARCHAR(50),

    mortality_flag               BOOLEAN,

    readmission_30_days_flag     BOOLEAN,

    insurance_type               VARCHAR(50),

    treatment_cost               NUMERIC(12,2)
        CHECK (treatment_cost >= 0),

    revenue_amount               NUMERIC(12,2)
        CHECK (revenue_amount >= 0),

    satisfaction_score           NUMERIC(5,2)
        CHECK (satisfaction_score BETWEEN 0 AND 100),

    complaint_flag               BOOLEAN,

    ambulance_arrival_flag       BOOLEAN,

    month                        INTEGER
        CHECK (month BETWEEN 1 AND 12),

    hospital_name                VARCHAR(150),

    latitude                     NUMERIC(10,6),

    longitude                    NUMERIC(10,6),

    created_at                   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_visit_patient
        FOREIGN KEY (patient_id)
        REFERENCES bronze.dim_patient(patient_id),

    CONSTRAINT fk_visit_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES bronze.dim_hospital(hospital_id),

    CONSTRAINT fk_visit_department
        FOREIGN KEY (department_id)
        REFERENCES bronze.dim_department(department_id),

    CONSTRAINT fk_visit_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES bronze.dim_doctor(doctor_id)
);