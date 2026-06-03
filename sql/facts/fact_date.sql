--------------------------------------------------------------------------------
-->> Create Production Grade Dimension Date Table
--------------------------------------------------------------------------------

CREATE TABLE bronze.dim_date (
    date_key            INTEGER PRIMARY KEY,

    full_date           DATE NOT NULL UNIQUE,

    year                INTEGER
        CHECK (year >= 2000),

    quarter             VARCHAR(10),

    month               INTEGER
        CHECK (month BETWEEN 1 AND 12),

    month_name          VARCHAR(20),

    week_number         INTEGER
        CHECK (week_number BETWEEN 1 AND 53),

    day_of_week         VARCHAR(20),

    day_number          INTEGER
        CHECK (day_number BETWEEN 1 AND 31),

    is_weekend          BOOLEAN,

    is_holiday          BOOLEAN,

    season              VARCHAR(20),

    is_winter           BOOLEAN,

    is_flu_season       BOOLEAN,

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_quarter
        CHECK (
            quarter IN (
                'Q1',
                'Q2',
                'Q3',
                'Q4'
            )
        ),

    CONSTRAINT chk_season
        CHECK (
            season IN (
                'Winter',
                'Spring',
                'Summer',
                'Autumn'
            )
        )
);