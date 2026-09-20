from pathlib import Path
import pandas as pd

# Paths
BASE_DIR = Path(__file__).resolve().parents[1]
RAW_PATH = BASE_DIR / "data" / "raw" / "incident_event_log.csv"
PROCESSED_PATH = BASE_DIR / "data" / "processed" / "incidents_clean.csv"

PROCESSED_PATH.parent.mkdir(parents=True, exist_ok=True)

# Load raw data
df = pd.read_csv(RAW_PATH)

print(f"Loaded {len(df):,} rows")

# 1. Replace dataset placeholders with actual missing values
df = df.replace("?", pd.NA)

  # -100 is an invalid incident state
df["incident_state"] = df["incident_state"].replace(
    ["-100", -100],
    pd.NA
)


# 2. Parse datetime columns
datetime_cols = [
    "opened_at",
    "sys_created_at",
    "sys_updated_at",
    "resolved_at",
    "closed_at",
]

for col in datetime_cols:
    df[col] = pd.to_datetime(
        df[col],
        dayfirst=True,
        errors="coerce"
    )


# 3. Create numeric versions of ordered categories
df["impact_level"] = (
    df["impact"]
    .str.extract(r"^(\d+)", expand=False)
    .astype("Int64")
)

df["urgency_level"] = (
    df["urgency"]
    .str.extract(r"^(\d+)", expand=False)
    .astype("Int64")
)

df["priority_level"] = (
    df["priority"]
    .str.extract(r"^(\d+)", expand=False)
    .astype("Int64")
)

# 4. Basic validation
assert df.duplicated().sum() == 0

assert df.duplicated(
    subset=["number", "sys_updated_at", "sys_mod_count"]
).sum() == 0

# 5. Save cleaned data
df.to_csv(PROCESSED_PATH, index=False)

print(f"Saved cleaned data to: {PROCESSED_PATH}")
print(f"Rows: {len(df):,}")
print(f"Columns: {len(df.columns)}")
print("\nMissing values after cleaning:")
print(df.isna().sum().sort_values(ascending=False).head(15))