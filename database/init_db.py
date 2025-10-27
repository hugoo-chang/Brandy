#!/usr/bin/env python3
"""
Database initialization script for Brandy
Creates database, runs schema, and sets up initial data
"""

import os
import sys
from pathlib import Path
import psycopg2
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
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
        self.port = os.getenv('DB_PORT', '5432')
        self.database = os.getenv('DB_NAME', 'brandy')
        self.user = os.getenv('DB_USER', 'postgres')
        self.password = os.getenv('DB_PASSWORD', '')
        self.schema_file = Path(__file__).parent / 'schema.sql'

    def get_connection(self, database='postgres'):
        """Create database connection"""
        try:
            conn = psycopg2.connect(
                host=self.host,
                port=self.port,
                database=database,
                user=self.user,
                password=self.password
            )
            return conn
        except psycopg2.Error as e:
            print(f"Error connecting to database: {e}")
            sys.exit(1)

    def database_exists(self):
        """Check if database exists"""
        conn = self.get_connection()
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()

        try:
            cursor.execute(
                "SELECT 1 FROM pg_database WHERE datname = %s",
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
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()

        try:
            if drop_existing and self.database_exists():
                print(f"Dropping existing database '{self.database}'...")
                cursor.execute(
                    sql.SQL("DROP DATABASE IF EXISTS {}").format(
                        sql.Identifier(self.database)
                    )
                )
                print(f"Database '{self.database}' dropped.")

            if not self.database_exists():
                print(f"Creating database '{self.database}'...")
                cursor.execute(
                    sql.SQL("CREATE DATABASE {}").format(
                        sql.Identifier(self.database)
                    )
                )
                print(f"Database '{self.database}' created successfully.")
            else:
                print(f"Database '{self.database}' already exists.")
        except psycopg2.Error as e:
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
            with open(self.schema_file, 'r') as f:
                schema_sql = f.read()

            cursor.execute(schema_sql)
            conn.commit()
            print("Schema executed successfully.")
        except psycopg2.Error as e:
            conn.rollback()
            print(f"Error running schema: {e}")
            sys.exit(1)
        finally:
            cursor.close()
            conn.close()

    def verify_setup(self):
        """Verify database setup by checking tables"""
        conn = self.get_connection(database=self.database)
        cursor = conn.cursor()

        try:
            cursor.execute("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_type = 'BASE TABLE'
                ORDER BY table_name
            """)

            tables = cursor.fetchall()
            print("\nDatabase tables created:")
            for table in tables:
                print(f"  - {table[0]}")

            cursor.execute("""
                SELECT table_name
                FROM information_schema.views
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)

            views = cursor.fetchall()
            if views:
                print("\nDatabase views created:")
                for view in views:
                    print(f"  - {view[0]}")

            return True
        except psycopg2.Error as e:
            print(f"Error verifying setup: {e}")
            return False
        finally:
            cursor.close()
            conn.close()

    def initialize(self, drop_existing=False):
        """Run complete initialization"""
        print("=" * 60)
        print("Brandy Database Initialization")
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
        description='Initialize Brandy database'
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
