import pandas as pd
from rich.console import Console
from rich.pretty import pprint

console = Console()

FILE_TO_LOAD = {
    "data/raw-data/region.csv": "region",
    "data/raw-data/hospitals.csv": "hospital",
    # "data/raw-data/department.csv": "department",
    # "data/raw-data/doctors.csv": "doctor",
    # "data/raw-data/patients.csv": "patient",
    # "data/raw-data/diagnosis.csv": "diagnosis",
    # "data/raw-data/patient_visit.csv": "patient_visits",
    # "data/raw-data/staff.csv": "staffing",
    # "data/raw-data/finance.csv": "financials",
    # "data/raw-data/date.csv": "date_data",
}


def load_datasets(files_dict: dict):
    """Generate the table name and its DataFrame one by one."""
    for file_path, table_name in FILE_TO_LOAD.items():
        df = pd.read_csv(file_path)
        df = df.drop(columns="Unnamed: 0", errors="ignore")
        yield table_name, df


if __name__ == "__main__":
    data_generator = load_datasets(FILE_TO_LOAD)

    for table_name, df in data_generator:
        print(f"\n\n\n{'==' * 25} {table_name} {'==' * 25}")

        print(f"{'--' * 30} Columns {'--' * 30}")
        pprint(df.columns)

        print(f"{'--' * 30} Info {'--' * 30}")
        print(df.info())

        print(f"{'--' * 30} Dataframe {'--' * 30}")
        pprint(df.head(3))

        input("Press Enter to load the next datasets ...")
df = df.iloc[1:].reset_index(drop=True)
