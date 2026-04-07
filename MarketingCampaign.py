# -*- coding: utf-8 -*-
"""
Created on Sat Apr  4 09:07:58 2026

@author: Sujal
"""

import pandas as pd

# Step 1: Load raw data
file_path = "C:/Users/Sujal/Downloads/Marketing_campaign dataset.xlsx"
df_raw = pd.read_excel(file_path, header=None)

print("Initial shape:", df_raw.shape)
print(df_raw.head())


# Step 2: Convert to string (IMPORTANT)
col_data = df_raw.iloc[:, 0].astype(str)

# Step 3: FORCE clean tabs (handles hidden characters)
col_data = col_data.str.replace(r'\t+', '\t', regex=True)


# Step 4: Split using tab
df_split = col_data.str.split('\t', expand=True)

print("After split shape:", df_split.shape)


# Step 5: Extract and FIX header
header = df_split.iloc[0]

# Clean header properly
header = header.astype(str).str.strip()

print("Header preview:", header.tolist())


# Step 6: Assign header + remove first row
df_clean = df_split.iloc[1:].copy()
df_clean.columns = header

df_clean.reset_index(drop=True, inplace=True)


# Step 7: Remove duplicate columns (critical)
df_clean = df_clean.loc[:, ~df_clean.columns.duplicated()]


# Step 8: Basic cleaning
df_clean = df_clean.replace('', pd.NA)
df_clean = df_clean.dropna(how='all')

# Strip spaces
for col in df_clean.columns:
    if df_clean[col].dtype == "object":
        df_clean[col] = df_clean[col].str.strip()


# Step 9: Convert numerics safely
for col in df_clean.columns:
    try:
        df_clean[col] = pd.to_numeric(df_clean[col])
    except:
        pass


# Step 10: SAVE (force comma CSV)
output_file = "cleaned_marketing_campaign_data.csv"
df_clean.to_csv(output_file, index=False, sep=",")

print("✅ File saved:", output_file)
print("Final shape:", df_clean.shape)



