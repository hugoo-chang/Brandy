#!/usr/bin/env python3
"""
Database initialization script for Brandy - MySQL Version
Creates database, runs schema, and sets up initial data
"""

import os
import sys
from pathlib import Path
import mysql.connector
from mysql.connector import Error
import argparse
from dotenv import load_dotenv

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

# Load environment variables
load_dotenv()


class DatabaseInitializer:
    """Handles database initialization and setup"""

    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = os.getenv('DB_PORT', '3306')
        self.database = os.getenv('DB_NAME', 'brandy')
        self.user = os.getenv('DB_USER', 'root')
        self.password = os.getenv('DB_PASSWORD', '')
        self.schema_file = Path(__file__).parent / 'schema_mysql.sql'

    def get_connection(self, database=None):
        """Create database connection"""
        try:
            conn = mysql.connector.connect(
                host=self.host,
                port=self.port,
                database=database,
                user=self.user,
                password=self.password,
                charset='utf8mb4',
                collation='utf8mb4_unicode_ci'
            )
            return conn
        except Error as e:
            print(f"Error connecting to database: {e}")
            sys.exit(1)

    def database_exists(self):
        """Check if database exists"""
        conn = self.get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute(
                "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = %s",
                (self.database,)
            )
            exists = cursor.fetchone() is not None
            return exists
        finally:
            cursor.close()
            conn.close()

    def create_database(self, drop_existing=False):
        """Create the database"""
        conn = self.get_connection()
        cursor = conn.cursor()

        try:
            if drop_existing and self.database_exists():
                print(f"Dropping existing database '{self.database}'...")
                cursor.execute(f"DROP DATABASE IF EXISTS `{self.database}`")
                print(f"Database '{self.database}' dropped.")

            if not self.database_exists():
                print(f"Creating database '{self.database}'...")
                cursor.execute(
                    f"CREATE DATABASE `{self.database}` "
                    f"CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
                )
                print(f"Database '{self.database}' created successfully.")
            else:
                print(f"Database '{self.database}' already exists.")
        except Error as e:
            print(f"Error creating database: {e}")
            sys.exit(1)
        finally:
            cursor.close()
            conn.close()

    def run_schema(self):
        """Run the schema SQL file"""
        if not self.schema_file.exists():
            print(f"Error: Schema file not found at {self.schema_file}")
            sys.exit(1)

        print(f"Running schema from {self.schema_file}...")

        conn = self.get_connection(database=self.database)
        cursor = conn.cursor()

        try:
            with open(self.schema_file, 'r', encoding='utf-8') as f:
                schema_sql = f.read()

            # Split by semicolons and execute each statement
            # Handle DELIMITER changes for stored procedures
            statements = []
            current_statement = []
            delimiter = ';'
            in_delimiter_block = False

            for line in schema_sql.split('\n'):
                line = line.strip()

                # Check for DELIMITER change
                if line.startswith('DELIMITER'):
                    if 'DELIMITER ;' in line:
                        delimiter = ';'
                        in_delimiter_block = False
                    else:
                        delimiter = '//'
                        in_delimiter_block = True
                    continue

                # Skip empty lines and comments
                if not line or line.startswith('--'):
                    continue

                current_statement.append(line)

                # Check if statement is complete
                if line.endswith(delimiter):
                    stmt = ' '.join(current_statement)
                    stmt = stmt.rstrip(delimiter).strip()
                    if stmt:
                        statements.append(stmt)
                    current_statement = []

            # Execute each statement
            for statement in statements:
                if statement.strip():
                    try:
                        cursor.execute(statement)
                        conn.commit()
                    except Error as e:
                        # Ignore "already exists" errors
                        if 'already exists' not in str(e).lower():
                            print(f"Warning: {e}")
                            print(f"Statement: {statement[:100]}...")

            print("Schema executed successfully.")
        except Error as e:
            conn.rollback()
            print(f"Error running schema: {e}")
            sys.exit(1)
        finally:
            cursor.close()
            conn.close()

    def verify_setup(self):
        """Verify database setup by checking tables"""
        conn = self.get_connection(database=self.database)
        cursor = conn.cursor(dictionary=True)

        try:
            cursor.execute("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = %s
                AND table_type = 'BASE TABLE'
                ORDER BY table_name
            """, (self.database,))

            tables = cursor.fetchall()
            print("\nDatabase tables created:")
            for table in tables:
                print(f"  - {table['table_name']}")

            cursor.execute("""
                SELECT table_name
                FROM information_schema.views
                WHERE table_schema = %s
                ORDER BY table_name
            """, (self.database,))

            views = cursor.fetchall()
            if views:
                print("\nDatabase views created:")
                for view in views:
                    print(f"  - {view['table_name']}")

            return True
        except Error as e:
            print(f"Error verifying setup: {e}")
            return False
        finally:
            cursor.close()
            conn.close()

    def initialize(self, drop_existing=False):
        """Run complete initialization"""
        print("=" * 60)
        print("Brandy Database Initialization - MySQL")
        print("=" * 60)
        print(f"\nDatabase Configuration:")
        print(f"  Host: {self.host}")
        print(f"  Port: {self.port}")
        print(f"  Database: {self.database}")
        print(f"  User: {self.user}")
        print()

        self.create_database(drop_existing=drop_existing)
        self.run_schema()

        if self.verify_setup():
            print("\n" + "=" * 60)
            print("Database initialization completed successfully!")
            print("=" * 60)
        else:
            print("\nWarning: Database verification failed.")
            sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Initialize Brandy database - MySQL'
    )
    parser.add_argument(
        '--drop',
        action='store_true',
        help='Drop existing database if it exists'
    )
    parser.add_argument(
        '--verify-only',
        action='store_true',
        help='Only verify existing database setup'
    )

    args = parser.parse_args()

    initializer = DatabaseInitializer()

    if args.verify_only:
        print("Verifying database setup...")
        if initializer.verify_setup():
            print("\nDatabase verification successful!")
        else:
            print("\nDatabase verification failed!")
            sys.exit(1)
    else:
        if args.drop:
            confirm = input(
                f"Are you sure you want to drop database '{initializer.database}'? "
                "This will delete all data. (yes/no): "
            )
            if confirm.lower() != 'yes':
                print("Operation cancelled.")
                sys.exit(0)

        initializer.initialize(drop_existing=args.drop)


if __name__ == '__main__':
    main()
