import pandas as pd
from rich import print
from rich.progress import track


FILE_TO_LOAD = {
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


for file_path, name in track(FILE_TO_LOAD.items(), "Column clean ..."):
    df = pd.read_csv(file_path)
    df = df.drop(columns="Unnamed: 0", errors="ignore")
    df.to_csv(file_path, index=False)
    print(f"Updated df {name}")
