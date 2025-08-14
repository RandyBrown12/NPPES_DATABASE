#!/usr/bin/env python3
import csv
import sys

if len(sys.argv) != 3:
    print("Usage: clean_nucc_taxonomy.py <input_csv> <output_csv>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Columns we want to keep (case-insensitive)
KEEP_COLS = ["code", "specialization", "definition"]

with open(input_file, newline='', encoding='utf-8-sig') as inf, open(output_file, 'w', newline='', encoding='utf-8') as outf:
    reader = csv.DictReader(inf)
    # Figure out which columns to keep from original header
    final_cols = [col for col in reader.fieldnames if col.strip().lower() in KEEP_COLS]
    writer = csv.DictWriter(outf, fieldnames=final_cols)
    writer.writeheader()
    for row in reader:
        outrow = {col: (row[col].strip() if row[col].strip() else "N/A") for col in final_cols}
        writer.writerow(outrow)
