from multiprocessing.pool import Pool
import pandas as pd
import argparse


# === SETTINGS ===
def clean_data(index: int, chunk: pd.DataFrame, output_csv: str) -> pd.DataFrame:
    """
    Perform data cleaning on a chunk of the Dataframe
    and output to a CSV file.

    This is also used for multiprocessing.
    """

    # Check for empty or whitespace cells and replace with 'N/A'
    chunk = chunk.map(lambda x: 'N/A' if str(x).strip() == '' else x)
    return chunk

def perform_data_cleaning(args):

    input_csv = args.input
    output_csv = args.output
    chunk_size = args.chunk_size

    if len(input_csv) == 0:
        raise ValueError("Input CSV file path must be a single string.")
    elif len(output_csv) == 0:
        raise ValueError("Output CSV file path must be a single string.")



    # Loop through in chunks for memory safety
    with pd.read_csv(input_csv, dtype=str, chunksize=chunk_size, keep_default_na=False, encoding='utf-8') as reader:
        # Grab and discard header from first chunk before performing multiprocessing.
        header_chunk = next(reader)
        clean_header_chunk = clean_data(0, header_chunk, output_csv)
        clean_header_chunk.to_csv(output_csv, mode='w', index=False, header=True)
        print(f"Processed header chunk")
        
        # Perform multiprocessing on the rest of the chunks
        batch_size = args.processes if args.processes > 0 else 1
        batch = []
        with Pool(processes=batch_size) as pool:
            for index, chunk in enumerate(reader, start=1):
                batch.append((index, chunk, output_csv))

                # If batch is full
                if len(batch) == batch_size:
                    # Clean the data in the chunk
                    cleaned_chunks = pool.starmap(clean_data, batch)
                    print(f"Processed batch of chunks {index - batch_size + 1}-{index}")
                    # Combine cleaned chunks and write to CSV
                    cleaned_chunk = pd.concat(cleaned_chunks)
                    cleaned_chunk.to_csv(output_csv, mode='a', index=False, header=False)
                    batch.clear()


            # If batch is not empty, process remaining chunks
            if batch:
                cleaned_chunks = pool.starmap(clean_data, batch)
                print(f"Processed remaining chunks")
                cleaned_chunk = pd.concat(cleaned_chunks)
                cleaned_chunk.to_csv(output_csv, mode='a', index=False, header=False)

    print(f"Done! Cleaned data saved to {output_csv}")

if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description='Process CSV data for staging')
    arg_parser.add_argument('-i', '--input', type=str, required=True, help='Input NPPES CSV file path')
    arg_parser.add_argument('-o', '--output', type=str, required=True, help='Output cleaned CSV file path')
    arg_parser.add_argument('-c', '--chunk_size', type=int, default=100000, help='Process the file into chunks of this size')
    arg_parser.add_argument('-p', '--processes', type=int, default=1, help='Number of processes to use for multiprocessing')
    args = arg_parser.parse_args()
    perform_data_cleaning(args)
