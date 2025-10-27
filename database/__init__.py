"""
Brandy Database Package

Provides database configuration, models, and utilities for tracking
form submissions, users, events, and trademark analysis results.
"""

from .db_config import (
    DatabaseConfig,
    DatabasePool,
    db_pool,
    get_connection,
    get_cursor,
    close_all_connections,
    execute_query,
    execute_many,
    insert_one,
    update_one,
    delete_one,
    to_json
)

from .models import (
    UserRepository,
    EventRepository,
    FormSubmissionRepository,
    GeneratedNameRepository,
    TrademarkCheckRepository,
    CacheRepository
)

__all__ = [
    # Config
    'DatabaseConfig',
    'DatabasePool',
    'db_pool',
    'get_connection',
    'get_cursor',
    'close_all_connections',
    'execute_query',
    'execute_many',
    'insert_one',
    'update_one',
    'delete_one',
    'to_json',

    # Models
    'UserRepository',
    'EventRepository',
    'FormSubmissionRepository',
    'GeneratedNameRepository',
    'TrademarkCheckRepository',
    'CacheRepository'
]

__version__ = '1.0.0'
