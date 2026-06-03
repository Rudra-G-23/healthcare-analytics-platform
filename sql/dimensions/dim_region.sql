--------------------------------------------------------------------------------
-->> Create Dimension Region Table
--------------------------------------------------------------------------------

CREATE TABLE public.dim_region (
    region_id      VARCHAR(20) PRIMARY KEY,
    region_name    VARCHAR(100) NOT NULL,
    population_m   NUMERIC(10,2),
    urban_rural    VARCHAR(20),
    avg_income_k   INTEGER,
    elderly_pct    NUMERIC(5,2),
    poverty_rate   NUMERIC(5,2)
);


--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Region Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_region (
    region_id      VARCHAR(20) PRIMARY KEY,
    region_name    VARCHAR(100) NOT NULL UNIQUE,
    population_m   NUMERIC(10,2) CHECK (population_m >= 0),
    urban_rural    VARCHAR(20) CHECK (urban_rural IN ('Urban', 'Rural', 'Mixed')),
    avg_income_k   INTEGER CHECK (avg_income_k >= 0),
    elderly_pct    NUMERIC(5,2) CHECK (elderly_pct BETWEEN 0 AND 100),
    poverty_rate   NUMERIC(5,2) CHECK (poverty_rate BETWEEN 0 AND 100),
    
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);