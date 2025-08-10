from concurrent.futures import ProcessPoolExecutor
import pandas as pd
import argparse
import threading
import queue
import pyarrow as pa
import pyarrow.csv as csv

# === SETTINGS ===
def write_pyarrow_chunk_to_csv(table: pa.Table, output_csv: str, append=False):
    sink = pa.BufferOutputStream()
    csv.write_csv(table, sink)
    csv_bytes = sink.getvalue().to_pybytes()
    csv_str = csv_bytes.decode('utf-8')

    mode = 'a' if append else 'w'

    with open(output_csv, mode, encoding='utf-8') as file:
        if append:
            lines = csv_str.splitlines()
            file.write('\n'.join(lines[1:]) + '\n')  # Skip header for appending
        else:
            file.write(csv_str)

def clean_series(series):
    """Perform simple clean and replace with N/A"""
    return series.astype(str).str.strip().replace('', 'N/A')

def clean_dataframe(chunk: pd.DataFrame) -> pd.DataFrame:
    """
    Perform data cleaning on a chunk of the Dataframe
    and output to a CSV file.

    Also, Performs multiprocessing.
    """

    # Perform data cleaning for each column by splitting the work to processors
    with ProcessPoolExecutor() as executor:
        futures = {executor.submit(clean_series, chunk[column]): column for column in chunk.columns}
        results = {}
        for future in futures:
            column = futures[future]
            results[column] = future.result()

    # Combine results back into the original DataFrame
    cleaned_chunk = pd.DataFrame(results, index=chunk.index)
    return cleaned_chunk

def producer(arguments, shared_queue: queue.Queue, max_queue_size: int):
    chunk_size = arguments.chunk_size // max_queue_size
    chunks_cleaned = 0
    with pd.read_csv(arguments.input_file, chunksize=chunk_size, keep_default_na=False) as reader:
        for chunk in reader:
            print(f"Cleaning chunk {chunks_cleaned + 1}")
            cleaned_chunk = clean_dataframe(chunk)
            shared_queue.put(cleaned_chunk)
            print(f"Chunk {chunks_cleaned + 1} cleaned")
            chunks_cleaned += 1
    shared_queue.put(None)  # Sentinel to signal end of data

def consumer(arguments, shared_queue):
    chunks_cleaned = 0
    while True:
        cleaned_chunk = shared_queue.get()
        if cleaned_chunk is None:
            break

        print(f"Processing chunk {chunks_cleaned + 1}")

        # Convert to PyArrow Table for faster serialization
        table = pa.Table.from_pandas(cleaned_chunk)

        if chunks_cleaned == 0:
            write_pyarrow_chunk_to_csv(table, arguments.output_file, append=False)
        else:
            write_pyarrow_chunk_to_csv(table, arguments.output_file, append=True)

        print(f"Chunk {chunks_cleaned + 1} processed")
        chunks_cleaned += 1
        shared_queue.task_done()

if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description='Process CSV data for staging')
    arg_parser.add_argument('-i', '--input_file', type=str, required=True, help='Input NPPES CSV file path')
    arg_parser.add_argument('-o', '--output_file', type=str, required=True, help='Output cleaned CSV file path')
    arg_parser.add_argument('-c', '--chunk_size', type=int, default=100000, help='Process the file into chunks of this size')
    args = arg_parser.parse_args()

    if len(args.input_file) == 0:
        raise ValueError("Input CSV file path must be a single string.")
    elif len(args.output_file) == 0:
        raise ValueError("Output CSV file path must be a single string.")

    # Perform Producer-Consumer Pattern for processing a large CSV file.
    MAXIMUM_QUEUE_SIZE = 3
    shared_queue = queue.Queue(maxsize=MAXIMUM_QUEUE_SIZE)

    producer_thread = threading.Thread(target=producer, args=(args, shared_queue, MAXIMUM_QUEUE_SIZE))
    consumer_thread = threading.Thread(target=consumer, args=(args, shared_queue))

    producer_thread.start()
    consumer_thread.start()

    producer_thread.join()
    consumer_thread.join()

    print(f"Processed file {args.output_file} has been completed!")
