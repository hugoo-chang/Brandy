"""
Database models and repository classes for Brandy - MySQL Version
Provides high-level interface for database operations
"""

from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import logging
import json

from .db_config_mysql import get_cursor, insert_one, update_one, execute_query, to_json

logger = logging.getLogger(__name__)


def parse_json_field(value):
    """Parse JSON field from MySQL (might be string or dict)"""
    if isinstance(value, str):
        try:
            return json.loads(value)
        except:
            return {}
    return value or {}


class UserRepository:
    """Repository for user operations"""

    @staticmethod
    def create(email: str, full_name: str = None, company_name: str = None,
               phone: str = None, country: str = None, metadata: dict = None) -> str:
        """Create a new user"""
        data = {
            'email': email,
            'full_name': full_name,
            'company_name': company_name,
            'phone': phone,
            'country': country,
            'metadata': to_json(metadata or {})
        }
        return insert_one('users', data)

    @staticmethod
    def get_by_id(user_id: str) -> Optional[Dict]:
        """Get user by ID"""
        query = "SELECT * FROM users WHERE id = %s"
        result = execute_query(query, (user_id,), fetch='one')
        if result:
            result['metadata'] = parse_json_field(result.get('metadata'))
        return result

    @staticmethod
    def get_by_email(email: str) -> Optional[Dict]:
        """Get user by email"""
        query = "SELECT * FROM users WHERE email = %s"
        result = execute_query(query, (email,), fetch='one')
        if result:
            result['metadata'] = parse_json_field(result.get('metadata'))
        return result

    @staticmethod
    def update(user_id: str, **kwargs) -> bool:
        """Update user information"""
        if 'metadata' in kwargs:
            kwargs['metadata'] = to_json(kwargs['metadata'])
        return update_one('users', user_id, kwargs)

    @staticmethod
    def update_last_login(user_id: str) -> bool:
        """Update user's last login timestamp"""
        query = "UPDATE users SET last_login = NOW() WHERE id = %s"
        with get_cursor() as cursor:
            cursor.execute(query, (user_id,))
            return cursor.rowcount > 0

    @staticmethod
    def list_all(limit: int = 100, offset: int = 0) -> List[Dict]:
        """List all users with pagination"""
        query = """
            SELECT * FROM users
            ORDER BY created_at DESC
            LIMIT %s OFFSET %s
        """
        results = execute_query(query, (limit, offset), fetch='all')
        for result in results:
            result['metadata'] = parse_json_field(result.get('metadata'))
        return results


class EventRepository:
    """Repository for event operations"""

    @staticmethod
    def create(event_type: str, user_id: str = None, event_name: str = None,
               ip_address: str = None, user_agent: str = None,
               session_id: str = None, referrer: str = None,
               metadata: dict = None) -> str:
        """Create a new event"""
        data = {
            'user_id': user_id,
            'event_type': event_type,
            'event_name': event_name,
            'ip_address': ip_address,
            'user_agent': user_agent,
            'session_id': session_id,
            'referrer': referrer,
            'metadata': to_json(metadata or {})
        }
        return insert_one('events', data)

    @staticmethod
    def get_by_user(user_id: str, limit: int = 50) -> List[Dict]:
        """Get events for a specific user"""
        query = """
            SELECT * FROM events
            WHERE user_id = %s
            ORDER BY created_at DESC
            LIMIT %s
        """
        results = execute_query(query, (user_id, limit), fetch='all')
        for result in results:
            result['metadata'] = parse_json_field(result.get('metadata'))
        return results

    @staticmethod
    def get_by_type(event_type: str, limit: int = 100) -> List[Dict]:
        """Get events by type"""
        query = """
            SELECT * FROM events
            WHERE event_type = %s
            ORDER BY created_at DESC
            LIMIT %s
        """
        results = execute_query(query, (event_type, limit), fetch='all')
        for result in results:
            result['metadata'] = parse_json_field(result.get('metadata'))
        return results

    @staticmethod
    def get_by_session(session_id: str) -> List[Dict]:
        """Get all events for a session"""
        query = """
            SELECT * FROM events
            WHERE session_id = %s
            ORDER BY created_at ASC
        """
        results = execute_query(query, (session_id,), fetch='all')
        for result in results:
            result['metadata'] = parse_json_field(result.get('metadata'))
        return results


class FormSubmissionRepository:
    """Repository for form submission operations"""

    @staticmethod
    def create(user_id: str = None, event_id: str = None,
               form_type: str = 'brief_brandy', status: str = 'completed',
               completion_percentage: int = 100, time_spent_seconds: int = None,
               metadata: dict = None) -> str:
        """Create a new form submission"""
        data = {
            'user_id': user_id,
            'event_id': event_id,
            'form_type': form_type,
            'status': status,
            'completion_percentage': completion_percentage,
            'time_spent_seconds': time_spent_seconds,
            'metadata': to_json(metadata or {})
        }
        return insert_one('form_submissions', data)

    @staticmethod
    def add_answer(submission_id: str, field_name: str, field_value: str,
                   field_type: str = 'text', field_order: int = None) -> str:
        """Add an answer to a form submission"""
        data = {
            'submission_id': submission_id,
            'field_name': field_name,
            'field_value': field_value,
            'field_type': field_type,
            'field_order': field_order
        }
        return insert_one('form_answers', data)

    @staticmethod
    def add_answers_bulk(submission_id: str, answers: Dict[str, Any]) -> int:
        """Add multiple answers to a form submission"""
        count = 0
        for idx, (field_name, value) in enumerate(answers.items()):
            field_type = 'text'
            if isinstance(value, list):
                field_type = 'checkbox'
                value = ','.join(value)

            FormSubmissionRepository.add_answer(
                submission_id, field_name, str(value), field_type, idx
            )
            count += 1
        return count

    @staticmethod
    def get_by_id(submission_id: str) -> Optional[Dict]:
        """Get form submission by ID"""
        query = "SELECT * FROM v_form_submissions_complete WHERE submission_id = %s"
        result = execute_query(query, (submission_id,), fetch='one')
        if result:
            result['answers'] = parse_json_field(result.get('answers'))
            result['metadata'] = parse_json_field(result.get('metadata'))
        return result

    @staticmethod
    def get_by_user(user_id: str, limit: int = 50) -> List[Dict]:
        """Get form submissions by user"""
        query = """
            SELECT * FROM v_form_submissions_complete
            WHERE user_id = %s
            ORDER BY submitted_at DESC
            LIMIT %s
        """
        results = execute_query(query, (user_id, limit), fetch='all')
        for result in results:
            result['answers'] = parse_json_field(result.get('answers'))
            result['metadata'] = parse_json_field(result.get('metadata'))
        return results

    @staticmethod
    def list_recent(limit: int = 100) -> List[Dict]:
        """List recent form submissions"""
        query = """
            SELECT * FROM v_form_submissions_complete
            ORDER BY submitted_at DESC
            LIMIT %s
        """
        results = execute_query(query, (limit,), fetch='all')
        for result in results:
            result['answers'] = parse_json_field(result.get('answers'))
            result['metadata'] = parse_json_field(result.get('metadata'))
        return results


class GeneratedNameRepository:
    """Repository for generated name operations"""

    @staticmethod
    def create(name: str, user_id: str = None, event_id: str = None,
               submission_id: str = None, style: str = None,
               category: str = None, probability: float = None,
               risk_level: str = None, scores: dict = None,
               top_conflicts: list = None, recommendation: str = None) -> str:
        """Create a new generated name record"""
        data = {
            'user_id': user_id,
            'event_id': event_id,
            'submission_id': submission_id,
            'name': name,
            'style': style,
            'category': category,
            'probability': probability,
            'risk_level': risk_level,
            'scores': to_json(scores or {}),
            'top_conflicts': to_json(top_conflicts or []),
            'recommendation': recommendation
        }
        return insert_one('generated_names', data)

    @staticmethod
    def get_by_user(user_id: str, limit: int = 100) -> List[Dict]:
        """Get generated names for a user"""
        query = """
            SELECT * FROM generated_names
            WHERE user_id = %s
            ORDER BY created_at DESC
            LIMIT %s
        """
        results = execute_query(query, (user_id, limit), fetch='all')
        for result in results:
            result['scores'] = parse_json_field(result.get('scores'))
            result['top_conflicts'] = parse_json_field(result.get('top_conflicts'))
        return results

    @staticmethod
    def get_by_submission(submission_id: str) -> List[Dict]:
        """Get generated names for a form submission"""
        query = """
            SELECT * FROM generated_names
            WHERE submission_id = %s
            ORDER BY created_at ASC
        """
        results = execute_query(query, (submission_id,), fetch='all')
        for result in results:
            result['scores'] = parse_json_field(result.get('scores'))
            result['top_conflicts'] = parse_json_field(result.get('top_conflicts'))
        return results

    @staticmethod
    def mark_favorite(name_id: str, is_favorite: bool = True) -> bool:
        """Mark/unmark a name as favorite"""
        return update_one('generated_names', name_id, {'is_favorite': is_favorite})

    @staticmethod
    def get_favorites(user_id: str) -> List[Dict]:
        """Get user's favorite names"""
        query = """
            SELECT * FROM generated_names
            WHERE user_id = %s AND is_favorite = TRUE
            ORDER BY created_at DESC
        """
        results = execute_query(query, (user_id,), fetch='all')
        for result in results:
            result['scores'] = parse_json_field(result.get('scores'))
            result['top_conflicts'] = parse_json_field(result.get('top_conflicts'))
        return results


class TrademarkCheckRepository:
    """Repository for trademark check operations"""

    @staticmethod
    def create(name: str, user_id: str = None, event_id: str = None,
               category: int = None, search_type: str = 'phonetic',
               probability: float = None, risk_level: str = None,
               scores: dict = None, conflicts: list = None) -> str:
        """Create a new trademark check record"""
        data = {
            'user_id': user_id,
            'event_id': event_id,
            'name': name,
            'category': category,
            'search_type': search_type,
            'probability': probability,
            'risk_level': risk_level,
            'scores': to_json(scores or {}),
            'conflicts_found': len(conflicts) if conflicts else 0,
            'conflicts': to_json(conflicts or [])
        }
        return insert_one('trademark_checks', data)

    @staticmethod
    def get_by_name(name: str, limit: int = 10) -> List[Dict]:
        """Get trademark checks for a specific name"""
        query = """
            SELECT * FROM trademark_checks
            WHERE name = %s
            ORDER BY checked_at DESC
            LIMIT %s
        """
        results = execute_query(query, (name, limit), fetch='all')
        for result in results:
            result['scores'] = parse_json_field(result.get('scores'))
            result['conflicts'] = parse_json_field(result.get('conflicts'))
        return results

    @staticmethod
    def get_recent(user_id: str = None, limit: int = 50) -> List[Dict]:
        """Get recent trademark checks"""
        if user_id:
            query = """
                SELECT * FROM trademark_checks
                WHERE user_id = %s
                ORDER BY checked_at DESC
                LIMIT %s
            """
            results = execute_query(query, (user_id, limit), fetch='all')
        else:
            query = """
                SELECT * FROM trademark_checks
                ORDER BY checked_at DESC
                LIMIT %s
            """
            results = execute_query(query, (limit,), fetch='all')

        for result in results:
            result['scores'] = parse_json_field(result.get('scores'))
            result['conflicts'] = parse_json_field(result.get('conflicts'))
        return results


class CacheRepository:
    """Repository for cached search operations"""

    @staticmethod
    def get(query: str, search_type: str, category: int = None) -> Optional[Dict]:
        """Get cached search result"""
        sql = """
            SELECT * FROM cached_searches
            WHERE query = %s AND search_type = %s
            AND (category = %s OR (category IS NULL AND %s IS NULL))
            AND expires_at > NOW()
        """
        result = execute_query(sql, (query, search_type, category, category), fetch='one')

        if result:
            # Parse JSON results
            result['results'] = parse_json_field(result.get('results'))

            # Update last accessed time and hit count
            update_query = """
                UPDATE cached_searches
                SET last_accessed_at = NOW(),
                    hit_count = hit_count + 1
                WHERE id = %s
            """
            with get_cursor() as cursor:
                cursor.execute(update_query, (result['id'],))

        return result

    @staticmethod
    def set(query: str, search_type: str, results: list,
            category: int = None, expiry_days: int = 7) -> str:
        """Cache a search result"""
        expires_at = datetime.now() + timedelta(days=expiry_days)

        data = {
            'query': query,
            'search_type': search_type,
            'category': category,
            'results': to_json(results),
            'expires_at': expires_at
        }

        # Check if cache entry exists
        existing = CacheRepository.get(query, search_type, category)
        if existing:
            # Update existing
            update_query = """
                UPDATE cached_searches
                SET results = %s, expires_at = %s, last_accessed_at = NOW()
                WHERE id = %s
            """
            with get_cursor() as cursor:
                cursor.execute(update_query, (to_json(results), expires_at, existing['id']))
            return existing['id']
        else:
            # Insert new
            return insert_one('cached_searches', data)

    @staticmethod
    def clear_expired() -> int:
        """Clear expired cache entries"""
        query = "CALL clean_expired_cache()"
        with get_cursor() as cursor:
            cursor.execute(query)
            result = cursor.fetchone()
            return result['deleted_count'] if result else 0

    @staticmethod
    def clear_all() -> int:
        """Clear all cache entries"""
        query = "DELETE FROM cached_searches"
        with get_cursor() as cursor:
            cursor.execute(query)
            return cursor.rowcount


# Example usage
if __name__ == '__main__':
    # Example: Create user and form submission
    try:
        # Create user
        user_id = UserRepository.create(
            email='demo@example.com',
            full_name='Demo User',
            company_name='Demo Company',
            country='Peru'
        )
        print(f"Created user: {user_id}")

        # Create event
        event_id = EventRepository.create(
            event_type='form_submission',
            user_id=user_id,
            event_name='Brief Brandy Form',
            ip_address='127.0.0.1'
        )
        print(f"Created event: {event_id}")

        # Create form submission
        submission_id = FormSubmissionRepository.create(
            user_id=user_id,
            event_id=event_id,
            completion_percentage=100
        )
        print(f"Created form submission: {submission_id}")

        # Add form answers
        answers = {
            'resumen': 'Plataforma de e-commerce para productos artesanales',
            'publico': 'Millennials y Gen Z interesados en productos sostenibles',
            'problema': 'Falta de acceso a productos artesanales auténticos',
            'competidor1': 'Etsy',
            'competidor2': 'Amazon Handmade',
            'personalidad': ['honesta', 'confiable', 'inspiradora']
        }

        count = FormSubmissionRepository.add_answers_bulk(submission_id, answers)
        print(f"Added {count} answers")

        # Retrieve submission
        submission = FormSubmissionRepository.get_by_id(submission_id)
        print(f"\nRetrieved submission: {submission['submission_id']}")
        print(f"User: {submission['full_name']} ({submission['email']})")
        print(f"Answers: {submission['answers']}")

    except Exception as e:
        print(f"Error: {e}")
        logger.exception("Error in example usage")
