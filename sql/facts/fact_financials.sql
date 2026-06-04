--------------------------------------------------------------------------------
-->> Create Fact Financials Table
--------------------------------------------------------------------------------

CREATE TABLE public.fact_financials (
    financial_record_id           VARCHAR(30) PRIMARY KEY,

    hospital_id                   VARCHAR(20) NOT NULL,
    year_int                      INTEGER,

    month_name                    INTEGER,
    visit_count                   INTEGER,

    operational_cost              NUMERIC(14,2),
    staffing_cost                 NUMERIC(14,2),
    emergency_department_cost     NUMERIC(14,2),
    icu_cost                      NUMERIC(14,2),
    revenue                       NUMERIC(14,2),
    profit_margin                 NUMERIC(6,2),
    government_funding            NUMERIC(14,2),
    equipment_investment          NUMERIC(14,2),

    expansion_projects_flag       BOOLEAN,
    bed_occupancy_rate            NUMERIC(5,2),
    avg_patient_satisfaction      NUMERIC(5,2),
    readmission_rate              NUMERIC(5,2),
    complaint_rate                NUMERIC(5,2),
    mortality_rate                NUMERIC(5,2),
    avg_wait_time_minutes         NUMERIC(10,2),

    total_overtime_hours          NUMERIC(12,2),
    avg_burnout_index             NUMERIC(5,2),
    total_staff_absences          INTEGER,
    hospital_name                 VARCHAR(150),
    latitude                      NUMERIC(10,6),
    longitude                     NUMERIC(10,6),
);


--------------------------------------------------------------------------------
-->> Create Production Grade Fact Financials Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.fact_financials (
    financial_record_id           VARCHAR(30) PRIMARY KEY,

    hospital_id                   VARCHAR(20) NOT NULL,

    year_int                          INTEGER
        CHECK (year >= 2000),

    month_name                         INTEGER
        CHECK (month_name BETWEEN 1 AND 12),

    visit_count                   INTEGER
        CHECK (visit_count >= 0),

    operational_cost              NUMERIC(14,2)
        CHECK (operational_cost >= 0),

    staffing_cost                 NUMERIC(14,2)
        CHECK (staffing_cost >= 0),

    emergency_department_cost     NUMERIC(14,2)
        CHECK (emergency_department_cost >= 0),

    icu_cost                      NUMERIC(14,2)
        CHECK (icu_cost >= 0),

    revenue                       NUMERIC(14,2)
        CHECK (revenue >= 0),

    profit_margin                 NUMERIC(6,2),

    government_funding            NUMERIC(14,2),

    equipment_investment          NUMERIC(14,2),

    expansion_projects_flag       BOOLEAN,

    bed_occupancy_rate            NUMERIC(5,2)
        CHECK (bed_occupancy_rate BETWEEN 0 AND 100),

    avg_patient_satisfaction      NUMERIC(5,2)
        CHECK (avg_patient_satisfaction BETWEEN 0 AND 100),

    readmission_rate              NUMERIC(5,2)
        CHECK (readmission_rate BETWEEN 0 AND 100),

    complaint_rate                NUMERIC(5,2)
        CHECK (complaint_rate BETWEEN 0 AND 100),

    mortality_rate                NUMERIC(5,2)
        CHECK (mortality_rate BETWEEN 0 AND 100),

    avg_wait_time_minutes         NUMERIC(10,2)
        CHECK (avg_wait_time_minutes >= 0),

    total_overtime_hours          NUMERIC(12,2)
        CHECK (total_overtime_hours >= 0),

    avg_burnout_index             NUMERIC(5,2)
        CHECK (avg_burnout_index BETWEEN 0 AND 100),

    total_staff_absences          INTEGER
        CHECK (total_staff_absences >= 0),

    hospital_name                 VARCHAR(150),

    latitude                      NUMERIC(10,6),

    longitude                     NUMERIC(10,6),

    created_at                    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_financials_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES bronze.dim_hospital(hospital_id)
);
