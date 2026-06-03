--------------------------------------------------------------------------------
-->> Create Dimension Department Table
--------------------------------------------------------------------------------

CREATE TABLE public.dim_department (
    department_id      VARCHAR(20) PRIMARY KEY,
    department_name    VARCHAR(100) NOT NULL UNIQUE,
    type               VARCHAR(50),
    icu_capable        BOOLEAN,

    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Department Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_department (
    department_id      VARCHAR(20) PRIMARY KEY,
    department_name    VARCHAR(100) NOT NULL UNIQUE,
    type               VARCHAR(50),
    icu_capable        BOOLEAN,

    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_department_type
        CHECK (
            type IN (
                'Clinical',
                'Diagnostic',
                'Support',
                'Administrative'
            )
        )
);