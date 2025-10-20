"""
Configuration settings for Brandy
"""

import os
from pathlib import Path

# Project paths
PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "data"
CACHE_DIR = DATA_DIR / "cache"

# Create directories if they don't exist
DATA_DIR.mkdir(exist_ok=True)
CACHE_DIR.mkdir(exist_ok=True)

# INDECOPI URLs
INDECOPI_SEARCH_URL = "https://pi.indecopi.gob.pe/buscatumarca/"
INDECOPI_API_URL = "https://pi.indecopi.gob.pe/buscatumarca/api/search"  # hypothetical

# Cache settings
CACHE_EXPIRY_DAYS = 7
ENABLE_CACHE = True

# Name generation settings
DEFAULT_MIN_LENGTH = 5
DEFAULT_MAX_LENGTH = 10
DEFAULT_NAME_COUNT = 10

# Phonetic algorithms weights
PHONETIC_ALGORITHMS = {
    'metaphone': 0.35,
    'soundex': 0.30,
    'nysiis': 0.25,
    'match_rating': 0.10
}

# Similarity thresholds
PHONETIC_SIMILARITY_THRESHOLD = 0.80  # 80% similar = potential conflict
SPELLING_SIMILARITY_THRESHOLD = 0.85  # 85% similar = potential conflict

# Probability calculation weights
PROBABILITY_WEIGHTS = {
    'distinctiveness': 0.40,
    'phonetic_conflicts': 0.30,
    'spelling_similarity': 0.20,
    'category_overlap': 0.10
}

# Name generation rules
VOWELS = ['a', 'e', 'i', 'o', 'u']
CONSONANTS = [
    'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm',
    'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'
]

# Common syllable patterns for Spanish phonetics
SPANISH_SYLLABLE_PATTERNS = [
    'CV',   # Consonant-Vowel (e.g., "ma")
    'CVC',  # Consonant-Vowel-Consonant (e.g., "mar")
    'VC',   # Vowel-Consonant (e.g., "ar")
    'V',    # Vowel alone (e.g., "a")
]

# Avoid these patterns (too generic/descriptive in Spanish)
FORBIDDEN_PATTERNS = [
    'super', 'mega', 'ultra', 'max', 'plus', 'pro', 'top',
    'best', 'perfect', 'premium', 'deluxe', 'royal', 'gold'
]

# Categories (NICE Classification)
TRADEMARK_CATEGORIES = {
    'technology': [9, 42],
    'food': [29, 30, 31, 32, 33],
    'clothing': [25],
    'services': [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
    'pharmaceutical': [5, 44],
    'cosmetics': [3],
    'general': list(range(1, 46))
}

# Selenium settings
SELENIUM_TIMEOUT = 10
HEADLESS_BROWSER = True

# API settings (if implementing REST API)
API_HOST = "0.0.0.0"
API_PORT = 8000
