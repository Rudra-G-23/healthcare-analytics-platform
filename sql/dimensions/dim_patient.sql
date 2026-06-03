--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Patient Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_patient (
    patient_id                  VARCHAR(20) PRIMARY KEY,

    age                         INTEGER
        CHECK (age BETWEEN 0 AND 120),

    gender                      VARCHAR(20),

    insurance_type              VARCHAR(50),

    chronic_conditions          TEXT,

    chronic_condition_count     INTEGER
        CHECK (chronic_condition_count >= 0),

    risk_category               VARCHAR(30),

    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_gender
        CHECK (
            gender IN (
                'Male',
                'Female',
                'Other'
            )
        ),

    CONSTRAINT chk_risk_category
        CHECK (
            risk_category IN (
                'Low',
                'Medium',
                'High',
                'Critical'
            )
        )
);