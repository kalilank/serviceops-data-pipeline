import pandas as pd

DATA_PATH = "data/raw/incident_event_log.csv"

df = pd.read_csv(DATA_PATH)

print("--- Exact Duplicate Rows ---")
print(df.duplicated().sum())

print("\n --- Suspicious Placeholder Values ---")
placeholders = ["?", "NA", "N/A", "NULL", "null", "None", "-100"]

for col in df.columns:
  values = df[col].astype(str)

  found = {}

  for placeholder in placeholders:
    count = (values == placeholder).sum()

    if count > 0:
      found[placeholder] = count

  if found:
    print(f"{col}: {found}")

print("\n--- Important Categorical Values ---")

categorical_columns = [
  "incident_state",
  "contact_type",
  "impact",
  "urgency",
  "priority",
  "made_sla",
]

for col in categorical_columns:
  print(f"\n{col}")
  print(df[col].value_counts(dropna=False))


print("\n--- Datetime Validation ---")

datetime_columns = [
  "opened_at",
  "closed_at",
  "resolved_at",
  "sys_created_at",
  "sys_updated_at",
]

for col in datetime_columns:
  parsed = pd.to_datetime(
    df[col],
    dayfirst=True,
    errors="coerce"
  )

  invalid = parsed.isnull().sum()

  print(
    f"{col}: "
    f"invalid={invalid:,}, "
    f"min={parsed.min()}, "
    f"max={parsed.max()}"
  )

print("\n--- Duplicate Event Keys ---")

duplicate_event_keys = df.duplicated(
  subset=[
    "number",
    "sys_created_at",
    "sys_mod_count"
  ]
).sum()

print(f"Duplicate Event Keys: {duplicate_event_keys}")