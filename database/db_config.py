"""
Database configuration and connection management for Brandy
"""

import os
from contextlib import contextmanager
from typing import Optional, Dict, Any
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor, Json
from dotenv import load_dotenv
import logging

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DatabaseConfig:
    """Database configuration settings"""

    def __init__(self):
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = int(os.getenv('DB_PORT', '5432'))
        self.database = os.getenv('DB_NAME', 'brandy')
        self.user = os.getenv('DB_USER', 'postgres')
        self.password = os.getenv('DB_PASSWORD', '')
        self.min_connections = int(os.getenv('DB_MIN_CONNECTIONS', '1'))
        self.max_connections = int(os.getenv('DB_MAX_CONNECTIONS', '10'))

    def get_connection_string(self) -> str:
        """Get database connection string"""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"

    def get_connection_params(self) -> Dict[str, Any]:
        """Get connection parameters as dictionary"""
        return {
            'host': self.host,
            'port': self.port,
            'database': self.database,
            'user': self.user,
            'password': self.password
        }


class DatabasePool:
    """Connection pool manager"""

    _instance: Optional['DatabasePool'] = None
    _pool: Optional[SimpleConnectionPool] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if self._pool is None:
            config = DatabaseConfig()
            try:
                self._pool = SimpleConnectionPool(
                    config.min_connections,
                    config.max_connections,
                    **config.get_connection_params()
                )
                logger.info("Database connection pool created successfully")
            except Exception as e:
                logger.error(f"Failed to create connection pool: {e}")
                raise

    @contextmanager
    def get_connection(self, cursor_factory=RealDictCursor):
        """
        Get database connection from pool

        Usage:
            with db_pool.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM users")
                    results = cursor.fetchall()
        """
        conn = self._pool.getconn()
        try:
            conn.cursor_factory = cursor_factory
            yield conn
            conn.commit()
        except Exception as e:
            conn.rollback()
            logger.error(f"Database error: {e}")
            raise
        finally:
            self._pool.putconn(conn)

    @contextmanager
    def get_cursor(self, cursor_factory=RealDictCursor):
        """
        Get database cursor (convenience method)

        Usage:
            with db_pool.get_cursor() as cursor:
                cursor.execute("SELECT * FROM users")
                results = cursor.fetchall()
        """
        with self.get_connection(cursor_factory=cursor_factory) as conn:
            cursor = conn.cursor()
            try:
                yield cursor
                conn.commit()
            except Exception as e:
                conn.rollback()
                raise
            finally:
                cursor.close()

    def close_all(self):
        """Close all connections in the pool"""
        if self._pool:
            self._pool.closeall()
            logger.info("All database connections closed")


# Global pool instance
db_pool = DatabasePool()


# Convenience functions
def get_connection(cursor_factory=RealDictCursor):
    """Get database connection from global pool"""
    return db_pool.get_connection(cursor_factory=cursor_factory)


def get_cursor(cursor_factory=RealDictCursor):
    """Get database cursor from global pool"""
    return db_pool.get_cursor(cursor_factory=cursor_factory)


def close_all_connections():
    """Close all connections in global pool"""
    db_pool.close_all()


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
        RETURNING id
    """

    result = execute_query(query, tuple(values), fetch='one')
    return result['id'] if result else None


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


def to_json(data: Any) -> Json:
    """
    Convert Python object to PostgreSQL JSON

    Args:
        data: Python object (dict, list, etc.)

    Returns:
        psycopg2 Json object
    """
    return Json(data)


# Example usage
if __name__ == '__main__':
    # Test database connection
    try:
        with get_cursor() as cursor:
            cursor.execute("SELECT version()")
            version = cursor.fetchone()
            print(f"Connected to: {version['version']}")

            # Test tables
            cursor.execute("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
            tables = cursor.fetchall()
            print(f"\nAvailable tables: {len(tables)}")
            for table in tables:
                print(f"  - {table['table_name']}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        close_all_connections()
