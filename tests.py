import psycopg2
import json
import subprocess

def test_database_connection():
    """
    Verify that a database connection can be established from the info.json file.
    This test is essential to be used for all other tests that require database access.
    """
    with open('info.json', 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    assert conn is not None
    conn.close()

def test_database_count_for_endpoints():
    """
    Verify that the count of records in the ENDPOINTS table matches the count in the CSV file.
    """
    with open('info.json', 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM ENDPOINTS")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/endpoint_pfile_20050523-20250608.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for endpoint does not match CSV count"

def test_database_count_for_npi():
    """
    Verify that the count of records in the NPI table matches the count in the CSV file.
    """
    with open('info.json', 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM PROVIDERS")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/npidata_cleaned.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for NPI does not match CSV count"

def test_database_count_for_othername():
    """
    Verify that the count of records in the PROVIDER_OTHERNAME table matches the count in the CSV file.
    """
    with open('info.json', 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM PROVIDER_OTHERNAME")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/othername_pfile_20050523-20250608.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for other names does not match CSV count"