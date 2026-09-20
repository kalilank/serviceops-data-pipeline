from pathlib import Path
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


# Project paths
BASE_DIR = Path(__file__).resolve().parents[1]
DATA_PATH = BASE_DIR / "data" / "processed" / "incidents_clean.csv"

# Load database credentials from .env
load_dotenv(BASE_DIR / ".env")

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")


# Build PostgreSQL connection
DATABASE_URL = URL.create(
    drivername="postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME,
)

engine = create_engine(DATABASE_URL)


# Columns that should be read as datetime
datetime_columns = [
    "opened_at",
    "sys_created_at",
    "sys_updated_at",
    "resolved_at",
    "closed_at",
]


print("Loading cleaned dataset...")

df = pd.read_csv(
    DATA_PATH,
    parse_dates=datetime_columns,
    dtype={
        "cmdb_ci": "string",
        "caused_by": "string",
    }
)

print(f"Loaded {len(df):,} rows from CSV.")


# Empty staging table before loading
# so rerunning the script does not duplicate data
with engine.begin() as connection:
    connection.execute(
        text(
            "TRUNCATE TABLE staging.incident_events "
            "RESTART IDENTITY;"
        )
    )


print("Loading data into PostgreSQL...")

df.to_sql(
    name="incident_events",
    con=engine,
    schema="staging",
    if_exists="append",
    index=False,
    chunksize=5000,
)


# Validate database row count
with engine.connect() as connection:
    database_count = connection.execute(
        text("SELECT COUNT(*) FROM staging.incident_events;")
    ).scalar_one()


print(f"CSV rows:      {len(df):,}")
print(f"Database rows: {database_count:,}")

assert database_count == len(df)

print("PostgreSQL load completed successfully.")