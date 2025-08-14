import os
import sys
import argparse
import threading
import queue
import pyarrow as pa
import pyarrow.csv as pacsv
import pyarrow.compute as pc

# === SETTINGS ===
def write_pyarrow_chunk_to_csv(table: pa.Table, output_csv: str, append=False) -> None:
    """
    Write a CSV file from a pyarrow table to output_csv.
    """
    if table is None or table.num_rows == 0:
        print("Empty table created")
        sys.exit(1)
    
    if not isinstance(output_csv, str):
        print("output_csv is not a string!")
        sys.exit(1)

    if not isinstance(append, bool):
        print("append is not a boolean!")
        sys.exit(1)

    write_options = pacsv.WriteOptions(
        include_header=not append,  # Only include header if not appending
        batch_size=65536  # Larger batch size for better performance
    )
    
    mode = 'ab' if append else 'wb'  # Use binary mode for better performance
    
    try:
        with open(output_csv, mode) as file:
            # Write directly to file instead of intermediate buffer
            pacsv.write_csv(table, file, write_options=write_options)
    except IOError as e:
        print(f"Error writing to {output_csv}: {e}")
        raise

def clean_string_column(arr: pa.Array, column_name: str) -> pa.Table:
    if not pa.types.is_string(arr.type):
        raise ValueError(f"Column '{column_name}' is not of string type.")
    elif not isinstance(column_name, str):
        raise TypeError(f"Column name '{column_name}' is not of string type.")
    
    default_value = pa.scalar('N/A')
    if column_name in ['Is Sole Proprietor', 'Is Organization Subpart','Affiliation']:
        default_value = pa.scalar('X')

    # Strip whitespace
    stripped = pc.utf8_trim_whitespace(arr)
    # Replace empty strings with 'N/A'
    replaced = pc.if_else(pc.equal(stripped, pa.scalar('')), default_value, stripped)
    return replaced

def clean_table(table: pa.Table) -> pa.Table:
    # For each column, if string type, apply clean_string_column
    columns = []
    for column_name in table.schema.names:
        column = table[column_name]
        if pa.types.is_string(column.type):
            cleaned_column = clean_string_column(column, column_name)
            columns.append(cleaned_column)
        else:
            columns.append(column)
    return pa.Table.from_arrays(columns, schema=table.schema)

def producer(arguments, shared_queue: queue.Queue):
    """
    The purpose of this producer is to produce chunks into a 
    queue for the consumer to read.
    """
    chunks_cleaned = 0

    # Read the file as they are all strings
    header_reader = pacsv.open_csv(arguments.input_file)

    first_batch = next(iter(header_reader))
    column_names = first_batch.schema.names
    column_types = {col_name: pa.string() for col_name in column_names}

    convert_options = pacsv.ConvertOptions(column_types=column_types)
    read_options = pacsv.ReadOptions(block_size=arguments.chunk_size)

    reader = pacsv.open_csv(arguments.input_file, convert_options=convert_options, read_options=read_options)

    for batch in reader:
        cleaned_chunk = clean_table(pa.Table.from_batches([batch]))
        shared_queue.put(cleaned_chunk)
        chunks_cleaned += 1
    shared_queue.put(None)  # Sentinel to signal end of data

def consumer(arguments, shared_queue):
    """
    The purpose of this consumer is to consume chunks from the queue
    and write them to the output CSV file.
    """
    chunks_cleaned = 0
    while True:
        try:
            cleaned_chunk = shared_queue.get(timeout=300)  # Set 5-minute timeout if taking too long
        except queue.TimeoutError:
            sys.exit(1)

        if cleaned_chunk is None:
            break

        write_pyarrow_chunk_to_csv(cleaned_chunk, arguments.output_file, append=(chunks_cleaned > 0))
        chunks_cleaned += 1
        shared_queue.task_done()

if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description='Process CSV data for staging')
    arg_parser.add_argument('-i', '--input_file', type=str, required=True, help='Input NPPES CSV file path')
    arg_parser.add_argument('-o', '--output_file', type=str, required=True, help='Output cleaned CSV file path')
    arg_parser.add_argument('-c', '--chunk_size', type=int, default=100000, help='Process the file into chunks of this size')
    args = arg_parser.parse_args()

    if not os.path.isfile(args.input_file):
        raise FileNotFoundError(f"Input file {args.input_file} does not exist.")
    elif args.chunk_size > 10000000:
        raise ValueError("Chunk size must be less than 10000000 to ensure efficient processing.")

    if os.path.exists(args.output_file):
        raise FileExistsError(f"Output file {args.output_file} already exists. Please choose a different output file name.")
    
    # Perform Producer-Consumer Pattern for processing a large CSV file.
    MAXIMUM_QUEUE_SIZE = 3
    shared_queue = queue.Queue(maxsize=MAXIMUM_QUEUE_SIZE)

    producer_thread = threading.Thread(target=producer, args=(args, shared_queue))
    consumer_thread = threading.Thread(target=consumer, args=(args, shared_queue))

    producer_thread.start()
    consumer_thread.start()

    producer_thread.join()
    consumer_thread.join()

    print(f"Processed file {args.output_file} has been completed!")
