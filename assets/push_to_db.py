
import os
import psycopg2
from dotenv import load_dotenv
from pathlib import Path

# --- File Paths ---
ASSETS_DIR = Path(__file__).parent
SQL_FILE = ASSETS_DIR / "data" / "generated_data.sql"
ENV_FILE = ASSETS_DIR / ".env"

def push_to_db():
    """
    Connects to the PostgreSQL database and executes the SQL script.
    """
    load_dotenv(dotenv_path=ENV_FILE)

    try:
        conn = psycopg2.connect(
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("HOST"),
            port=os.getenv("PORT")
        )
        conn.autocommit = True
        cursor = conn.cursor()

        print("Connecting to the database...")

        with open(SQL_FILE, "r", encoding="utf-8") as f:
            sql_script = f.read()
            # Split the script into individual statements to execute them one by one.
            # This is a simple split, which might not work for complex scripts with semicolons inside strings or comments.
            # For this generated script, it should be fine.
            for statement in sql_script.split(';'):
                if statement.strip():
                    cursor.execute(statement)

        print("Data successfully pushed to the database.")

    except psycopg2.Error as e:
        print(f"Error connecting to or writing to the database: {e}")
    finally:
        if 'conn' in locals() and conn:
            cursor.close()
            conn.close()
            print("Database connection closed.")

if __name__ == "__main__":
    if not SQL_FILE.exists():
        print(f"Error: The SQL file was not found at {SQL_FILE}")
        print("Please run the `generate_data.py` script first to generate the data.")
    else:
        push_to_db()
