import pandas as pd
from rich import print
from rich.progress import track
from rich.traceback import install

install()

path = r"data/raw-data/all-in-one-healthcare-data.xlsx"

conversion_map = {
    "Dim_Region": "data/raw-data/region.csv",
    "Dim_Hospital": "data/raw-data/hospitals.csv",
    "Dim_Department": "data/raw-data/department.csv",
    "Dim_Doctor": "data/raw-data/doctors.csv",
    "Dim_Patient": "data/raw-data/patients.csv",
    "Dim_Diagnosis": "data/raw-data/diagnosis.csv",
    "Fact_Patient_Visits": "data/raw-data/patient_visit.csv",
    "Fact_Staffing": "data/raw-data/staff.csv",
    "Fact_Financials": "data/raw-data/finance.csv",
    "Dim_Date": "data/raw-data/date.csv",
    "Vocabulary": "data/raw-data/vocab.csv",
}


for sheet, csv_path in track(conversion_map.items(), "Converting Excel to CSV..."):
    df = pd.read_excel(path, sheet_name=sheet)
    df.to_csv(csv_path, index=True)

print("\n\n[bold green]xlsx to csv conversion complected.[/bold green]")
