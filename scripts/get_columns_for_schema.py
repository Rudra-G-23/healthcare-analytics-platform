import pandas as pd
from rich.console import Console
from rich.pretty import pprint

console = Console()

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
    "data/raw-data/vocab.csv": "Vocab",
}

for file_path, table_name in files_to_load.items():
    df = pd.read_csv(file_path)
    print(f"{'==' * 25} {table_name} {'==' * 25}")

    print(f"{'--' * 30} Columns {'--' * 30}")
    pprint(df.columns)

    print(f"{'--' * 30} Info {'--' * 30}")
    print(df.info())

    print(f"{'--' * 30} Dataframe {'--' * 30}")
    pprint(df.head(3))
