import sys
import subprocess
import os

this_directory = os.path.dirname(os.path.abspath(__file__))
repository_directory = os.path.dirname(this_directory)
def test_error_for_invalid_input_file():
    """Test the argument parsing logic for invalid input file."""
    result = subprocess.run(
        [
            sys.executable, 
            os.path.join(repository_directory, 'db_staging.py'), 
            '--input_file', 
            'input.csv', 
            '--output_file', 
            'output.csv'
        ],
        capture_output=True,
        text=True
    )

    assert "FileNotFoundError" in result.stderr, "Expected 'FileNotFoundError' error message"

def test_error_for_found_output_file():
    """Test the argument parsing logic for found output file."""
    result = subprocess.run(
        [
            sys.executable,
            os.path.join(repository_directory, 'db_staging.py'),
            '--input_file',
            os.path.join(repository_directory, 'tests/test_data/othername_test.csv'),
            '--output_file',
            os.path.join(repository_directory, 'tests/test_data/pl_test.csv')
        ],
        capture_output=True,
        text=True
    )

    assert "FileExistsError" in result.stderr, "Expected 'FileExistsError' error message"

def test_error_for_non_number_chunk():
    result = subprocess.run(
        [
            sys.executable,
            os.path.join(repository_directory, 'db_staging.py'),
            '--input_file',
            os.path.join(repository_directory, 'tests/test_data/othername_test.csv'),
            '--output_file',
            os.path.join(repository_directory, 'tests/test_data/output.csv'),
            '--chunk_size',
            'not_a_number'
        ],
        capture_output=True,
        text=True
    )

    assert "invalid int value" in result.stderr, "Invalid int value not found in stderr"