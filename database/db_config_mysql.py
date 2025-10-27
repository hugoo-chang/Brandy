"""
Database configuration and connection management for Brandy - MySQL Version
"""

import os
from contextlib import contextmanager
from typing import Optional, Dict, Any
import mysql.connector
from mysql.connector import pooling
from mysql.connector.cursor import MySQLCursorDict
from dotenv import load_dotenv
import logging
import json

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DatabaseConfig:
    """Database configuration settings"""

    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = int(os.getenv('DB_PORT', '3306'))
        self.database = os.getenv('DB_NAME', 'brandy')
        self.user = os.getenv('DB_USER', 'root')
        self.password = os.getenv('DB_PASSWORD', '')
        self.pool_name = 'brandy_pool'
        self.pool_size = int(os.getenv('DB_MAX_CONNECTIONS', '10'))

    def get_connection_params(self) -> Dict[str, Any]:
        """Get connection parameters as dictionary"""
        return {
            'host': self.host,
            'port': self.port,
            'database': self.database,
            'user': self.user,
            'password': self.password,
            'charset': 'utf8mb4',
            'collation': 'utf8mb4_unicode_ci',
            'autocommit': False
        }


class DatabasePool:
    """Connection pool manager"""

    _instance: Optional['DatabasePool'] = None
    _pool: Optional[pooling.MySQLConnectionPool] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if self._pool is None:
            config = DatabaseConfig()
            try:
                self._pool = pooling.MySQLConnectionPool(
                    pool_name=config.pool_name,
                    pool_size=config.pool_size,
                    **config.get_connection_params()
                )
                logger.info("MySQL connection pool created successfully")
            except Exception as e:
                logger.error(f"Failed to create connection pool: {e}")
                raise

    @contextmanager
    def get_connection(self):
        """
        Get database connection from pool

        Usage:
            with db_pool.get_connection() as conn:
                with conn.cursor(dictionary=True) as cursor:
                    cursor.execute("SELECT * FROM users")
                    results = cursor.fetchall()
        """
        conn = self._pool.get_connection()
        try:
            yield conn
            conn.commit()
        except Exception as e:
            conn.rollback()
            logger.error(f"Database error: {e}")
            raise
        finally:
            conn.close()

    @contextmanager
    def get_cursor(self):
        """
        Get database cursor (convenience method)

        Usage:
            with db_pool.get_cursor() as cursor:
                cursor.execute("SELECT * FROM users")
                results = cursor.fetchall()
        """
        with self.get_connection() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                yield cursor
                conn.commit()
            except Exception as e:
                conn.rollback()
                raise
            finally:
                cursor.close()


# Global pool instance
db_pool = DatabasePool()


# Convenience functions
def get_connection():
    """Get database connection from global pool"""
    return db_pool.get_connection()


def get_cursor():
    """Get database cursor from global pool"""
    return db_pool.get_cursor()


# SQL query helpers
def execute_query(query: str, params: tuple = None, fetch: str = 'all') -> Any:
    """
    Execute a SQL query and return results

    Args:
        query: SQL query string
        params: Query parameters tuple
        fetch: 'all', 'one', or 'none'

    Returns:
        Query results or None
    """
    with get_cursor() as cursor:
        cursor.execute(query, params or ())

        if fetch == 'all':
            return cursor.fetchall()
        elif fetch == 'one':
            return cursor.fetchone()
        else:
            return None


def execute_many(query: str, params_list: list) -> int:
    """
    Execute a SQL query multiple times with different parameters

    Args:
        query: SQL query string
        params_list: List of parameter tuples

    Returns:
        Number of rows affected
    """
    with get_cursor() as cursor:
        cursor.executemany(query, params_list)
        return cursor.rowcount


def insert_one(table: str, data: Dict[str, Any]) -> Optional[str]:
    """
    Insert a single row and return the ID

    Args:
        table: Table name
        data: Dictionary of column: value pairs

    Returns:
        UUID of inserted row
    """
    columns = list(data.keys())
    values = list(data.values())
    placeholders = ', '.join(['%s'] * len(values))
    columns_str = ', '.join(columns)

    query = f"""
        INSERT INTO {table} ({columns_str})
        VALUES ({placeholders})
    """

    with get_cursor() as cursor:
        # Generate UUID for the id field
        cursor.execute("SELECT UUID() as new_id")
        new_id = cursor.fetchone()['new_id']

        # Add id to the data
        all_columns = ['id'] + columns
        all_values = [new_id] + values
        placeholders = ', '.join(['%s'] * len(all_values))
        columns_str = ', '.join(all_columns)

        query = f"INSERT INTO {table} ({columns_str}) VALUES ({placeholders})"
        cursor.execute(query, tuple(all_values))

        return new_id


def update_one(table: str, id: str, data: Dict[str, Any]) -> bool:
    """
    Update a single row by ID

    Args:
        table: Table name
        id: UUID of row to update
        data: Dictionary of column: value pairs

    Returns:
        True if row was updated
    """
    if not data:
        return False

    set_clause = ', '.join([f"{col} = %s" for col in data.keys()])
    values = list(data.values()) + [id]

    query = f"""
        UPDATE {table}
        SET {set_clause}
        WHERE id = %s
    """

    with get_cursor() as cursor:
        cursor.execute(query, tuple(values))
        return cursor.rowcount > 0


def delete_one(table: str, id: str) -> bool:
    """
    Delete a single row by ID

    Args:
        table: Table name
        id: UUID of row to delete

    Returns:
        True if row was deleted
    """
    query = f"DELETE FROM {table} WHERE id = %s"

    with get_cursor() as cursor:
        cursor.execute(query, (id,))
        return cursor.rowcount > 0


def to_json(data: Any) -> str:
    """
    Convert Python object to JSON string for MySQL

    Args:
        data: Python object (dict, list, etc.)

    Returns:
        JSON string
    """
    return json.dumps(data)


# Example usage
if __name__ == '__main__':
    # Test database connection
    try:
        with get_cursor() as cursor:
            cursor.execute("SELECT VERSION() as version")
            version = cursor.fetchone()
            print(f"Connected to: MySQL {version['version']}")

            # Test tables
            cursor.execute("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = DATABASE()
                ORDER BY table_name
            """)
            tables = cursor.fetchall()
            print(f"\nAvailable tables: {len(tables)}")
            for table in tables:
                print(f"  - {table['table_name']}")

    except Exception as e:
        print(f"Error: {e}")
