import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()
db_password = os.environ.get("DB_PASSWORD")

USERNAME: str = "admin"
PASSWORD: str = db_password
HOST: str = "localhost"
PORT: int = "5432"
DB_NAME: str = "healthcare_dw"

conn_string = f"postgresql+psycopg2://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}"
engine = create_engine(conn_string)

files_to_load = {
    "data/raw-data/region.csv": "region",
    "data/raw-data/hospitals.csv": "hospital",
    "data/raw-data/department.csv": "department",
    "data/raw-data/doctors.csv": "doctor",
    "data/raw-data/patients.csv": "patient",
    "data/raw-data/diagnosis.csv": "diagnosis",
    "data/raw-data/patient_visit.csv": "patient_visits",
    "data/raw-data/staff.csv": "staffing",
    "data/raw-data/finance.csv": "financials",
    "data/raw-data/date.csv": "date_data",
}


for file_path, table_name in files_to_load.items():
    try:
        df = pd.read_csv(file_path)
        df.to_sql(table_name, engine, if_exists="replace", index=False)
        print(f"Success! Loaded {file_path} into {table_name}")

    except Exception as e:
        print(f"Error loading {file_path}: {e}")

engine.dispose()
