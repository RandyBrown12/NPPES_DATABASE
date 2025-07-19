import pandas as pd

# === SETTINGS ===
input_csv = 'npidata_pfile_20050523-20250608.csv'         # Your original, big file
output_csv = 'npidata_staging_cleaned.csv'                # Cleaned file to use for Postgres load
chunk_size = 100000                                      # Tune this for your RAM, e.g. 100k–500k

# Loop through in chunks for memory safety
with pd.read_csv(input_csv, dtype=str, chunksize=chunk_size, keep_default_na=False, encoding='utf-8') as reader:
    for i, chunk in enumerate(reader):
        # Fill all empty or whitespace cells with 'N/A'
        chunk = chunk.applymap(lambda x: 'N/A' if str(x).strip() == '' else x)
        # First chunk: write header, others: append (no header)
        chunk.to_csv(output_csv, mode='w' if i == 0 else 'a', index=False, header=(i == 0))

print(f"Done! Cleaned data saved to {output_csv}")
