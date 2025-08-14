import datetime
import json
import psycopg2
import os

def main():
    """
    This is the main function connecting to the database with following summary requirements:

    - Total number of providers
    - Total number of type one providers
    - Total number of type two providers
    """
    current_path = os.path.dirname(__file__)
    info_path = os.path.join(os.path.dirname(current_path), 'info.json')
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
    cursor.execute("SELECT COUNT(*) FROM PROVIDERS")
    providers_count = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM PROVIDERS WHERE PROVIDER_ORGANIZATION_NAME = 'N/A' AND PROVIDER_LAST_NAME != 'N/A' AND PROVIDER_FIRST_NAME != 'N/A'")
    type_one_providers_count = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM PROVIDERS WHERE PROVIDER_ORGANIZATION_NAME != 'N/A' AND PROVIDER_LAST_NAME = 'N/A' AND PROVIDER_FIRST_NAME = 'N/A'")
    type_two_providers_count = cursor.fetchone()[0]

    log_message(f"Total number of providers: {providers_count}")
    log_message(f"Total number of type one providers: {type_one_providers_count}")
    log_message(f"Total number of type two providers: {type_two_providers_count}")
    log_message(f"Total number of providers with unknown organization: {providers_count - type_one_providers_count - type_two_providers_count}")
    
    cursor.close()
    conn.close()

def log_message(message):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

if __name__ == "__main__":
    main()
