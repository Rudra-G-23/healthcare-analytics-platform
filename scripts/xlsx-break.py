import pandas as pd
from rich import print
from rich.progress import track
from rich.traceback import install

install()

path = r"data/raw-data/all-in-one-healthcare-data.xlsx"

dim_region = pd.read_excel(path, sheet_name="Dim_Region")
dim_hospital = pd.read_excel(path, sheet_name="Dim_Hospital")
dim_department = pd.read_excel(path, sheet_name="Dim_Department")
dim_dr = pd.read_excel(path, sheet_name="Dim_Doctor")
dim_diagnosis = pd.read_excel(path, sheet_name="Dim_Diagnosis")
dim_patients = pd.read_excel(path, sheet_name="Dim_Patient")

fact_patient_visits = pd.read_excel(path, sheet_name="Fact_Patient_Visits")
fact_staffing = pd.read_excel(path, sheet_name="Fact_Staffing")
fact_finance = pd.read_excel(path, sheet_name="Fact_Financials")

date = pd.read_excel(path, sheet_name="Dim_Date")
vocab = pd.read_excel(path, sheet_name="Vocabulary")

dfs_to_save = {
    "data/raw-data/region.csv": dim_region,
    "data/raw-data/hospitals.csv": dim_hospital,
    "data/raw-data/department.csv": dim_department,
    "data/raw-data/doctors.csv": dim_dr,
    "data/raw-data/patients.csv": dim_patients,
    "data/raw-data/patient_visit.csv": fact_patient_visits,
    "data/raw-data/staff.csv": fact_staffing,
    "data/raw-data/finance.csv": fact_finance
}

for filename, df_obj in track(dfs_to_save.items(), "Saving files ..."):
    df_obj.to_csv(filename, index=False)
print("\n\n[bold green]xlsx to csv conversion complected.[/bold green]")