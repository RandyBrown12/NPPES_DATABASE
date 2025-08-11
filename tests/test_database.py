import psycopg2
import json
import subprocess
import os

os_path = os.path.dirname(os.path.abspath(__file__))
def test_database_connection():
    """
    Verify that a database connection can be established from the info.json file.
    This test is essential to be used for all other tests that require database access.
    """
    info_path = os.path.join(os_path, 'info.json')
    with open(info_path, 'r') as file:
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
    info_path = os.path.join(os_path, 'info.json')
    with open(info_path, 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM ENDPOINTS WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE);")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/endpoint_cleaned.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for endpoint does not match CSV count"

def test_database_count_for_npi():
    """
    Verify that the count of records in the NPI table matches the count in the CSV file.
    """
    info_path = os.path.join(os_path, 'info.json')
    with open(info_path, 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM PROVIDERS WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE);")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/npidata_cleaned.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for NPI does not match CSV count"

def test_database_count_for_othername():
    """
    Verify that the count of records in the PROVIDER_OTHERNAME table matches the count in the CSV file.
    """
    info_path = os.path.join(os_path, 'info.json')
    with open(info_path, 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM PROVIDER_OTHERNAME WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE);")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/othername_cleaned.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for other names does not match CSV count"

def test_database_count_for_pl():
    """
    Verify that the count of records in the provider_secondary_practice_location table matches the count in the CSV file.
    """
    info_path = os.path.join(os_path, 'info.json')
    with open(info_path, 'r') as file:
        info = json.load(file)
    conn = psycopg2.connect(
        dbname=info["database"],
        user=info["user"],
        password=info["password"],
        host=info["host"],
        port=info["port"]
    )
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM provider_secondary_practice_location WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE);")
    database_count = cursor.fetchone()[0]
    word_count_command = ["wc", "-l", "Original_data/pl_cleaned.csv"]
    csv_count_output = subprocess.run(word_count_command, capture_output=True, text=True)
    csv_count = (int(csv_count_output.stdout.split()[0]) - 1) # Subtracting 1 for header row
    assert database_count == csv_count, "Database count for provider_secondary_practice_location does not match CSV count"