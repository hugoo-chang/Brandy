"""
Spanish/Peruvian-Enhanced Brand Name Generator

Generates brand names that resonate with Spanish-speaking audiences in Peru.
Uses Spanish phonetics, Peruvian cultural elements, and natural pronunciation patterns.
"""

import random
import re
from typing import List, Optional, Set
from .spanish_config import (
    SPANISH_VOWELS,
    QUECHUA_VOWELS,
    SPANISH_CONSONANTS,
    SPANISH_CLUSTERS,
    SPANISH_SYLLABLE_PATTERNS,
    PERUVIAN_PREFIXES,
    SPANISH_SUFFIXES,
    COMMON_SPANISH_SYLLABLES,
    SPANISH_FORBIDDEN_PATTERNS,
    AVOID_CLUSTERS,
    SPANISH_WORD_ROOTS,
)


class SpanishBrandNameGenerator:
    """
    Generates culturally-aware brand names for Spanish-speaking audiences in Peru.
    """

    def __init__(self, use_quechua_influence: bool = True):
        """
        Initialize the Spanish brand name generator.

        Args:
            use_quechua_influence: Use Quechua-influenced phonetics (3-vowel system)
        """
        self.use_quechua = use_quechua_influence

        # Choose vowel system
        self.vowels = QUECHUA_VOWELS if use_quechua_influence else SPANISH_VOWELS
        self.all_vowels = SPANISH_VOWELS  # For variation
        self.consonants = SPANISH_CONSONANTS
        self.clusters = SPANISH_CLUSTERS
        self.syllable_patterns = SPANISH_SYLLABLE_PATTERNS

        # Culturally-resonant elements
        self.peruvian_prefixes = PERUVIAN_PREFIXES
        self.spanish_suffixes = SPANISH_SUFFIXES
        self.common_syllables = COMMON_SPANISH_SYLLABLES
        self.word_roots = SPANISH_WORD_ROOTS

        # Forbidden patterns
        self.forbidden = SPANISH_FORBIDDEN_PATTERNS
        self.avoid_clusters = AVOID_CLUSTERS

    def generate(
        self,
        count: int = 10,
        min_length: int = 4,
        max_length: int = 10,
        category: str = 'general',
        style: str = 'spanish_evocative',
        cultural_weight: float = 0.3
    ) -> List[str]:
        """
        Generate Spanish/Peruvian brand names.

        Args:
            count: Number of names to generate
            min_length: Minimum name length
            max_length: Maximum name length
            category: Business category (affects word roots used)
            style: Generation style
                - 'spanish_evocative': Culturally resonant, meaningful
                - 'spanish_syllabic': Natural Spanish syllables
                - 'peruvian_cultural': Emphasizes Peruvian heritage
                - 'modern_spanish': Contemporary Spanish with tech feel
                - 'hybrid': Mix of all
            cultural_weight: How much to emphasize Peruvian elements (0.0-1.0)

        Returns:
            List of culturally-appropriate brand names
        """
        names = set()
        attempts = 0
        max_attempts = count * 15

        while len(names) < count and attempts < max_attempts:
            attempts += 1

            # Choose generation method based on style
            if style == 'spanish_evocative':
                name = self._generate_spanish_evocative(category)
            elif style == 'spanish_syllabic':
                name = self._generate_spanish_syllabic(min_length, max_length)
            elif style == 'peruvian_cultural':
                name = self._generate_peruvian_cultural(category)
            elif style == 'modern_spanish':
                name = self._generate_modern_spanish(category)
            else:  # hybrid
                # Weight towards Peruvian cultural if specified
                if random.random() < cultural_weight:
                    name = self._generate_peruvian_cultural(category)
                else:
                    methods = [
                        self._generate_spanish_evocative,
                        self._generate_spanish_syllabic,
                        self._generate_modern_spanish,
                    ]
                    method = random.choice(methods)
                    if method == self._generate_spanish_syllabic:
                        name = method(min_length, max_length)
                    else:
                        name = method(category)

            # Validate
            if self._is_valid_spanish_name(name, min_length, max_length):
                names.add(name)

        return list(names)

    def _generate_spanish_evocative(self, category: str) -> str:
        """Generate evocative Spanish names using cultural word roots."""
        strategies = [
            # Word root + Spanish suffix
            lambda: self._get_word_root(category) + random.choice(self.spanish_suffixes),

            # Peruvian prefix + suffix
            lambda: random.choice(self.peruvian_prefixes) + random.choice(self.spanish_suffixes),

            # Common syllable + word root
            lambda: random.choice(self.common_syllables) + self._get_word_root(category),

            # Two word roots combined
            lambda: self._get_word_root(category) + self._get_word_root(category),

            # Cluster + vowel + suffix
            lambda: random.choice(self.clusters) + random.choice(self.vowels) + random.choice(self.spanish_suffixes),
        ]

        name = random.choice(strategies)()
        return self._capitalize_spanish(name)

    def _generate_spanish_syllabic(self, min_length: int, max_length: int) -> str:
        """Generate using natural Spanish syllables."""
        target_length = random.randint(min_length, max_length)
        name = ""

        # Start with common Spanish syllables 70% of the time
        if random.random() < 0.7:
            name = random.choice(self.common_syllables)

        while len(name) < target_length:
            # Use common syllables 60% of the time, generate new 40%
            if random.random() < 0.6:
                syllable = random.choice(self.common_syllables)
            else:
                syllable = self._create_spanish_syllable()

            name += syllable

            # Occasionally add Spanish clusters for impact
            if random.random() < 0.2 and len(name) < target_length - 2:
                cluster = random.choice(self.clusters)
                if cluster not in name:  # Avoid repetition
                    name += cluster + random.choice(self.vowels)

        # Trim to length
        name = name[:target_length]

        # Spanish names often end in vowels - ensure this 70% of the time
        if random.random() < 0.7 and name and name[-1] not in self.all_vowels:
            name = name[:-1] + random.choice(self.vowels)

        return self._capitalize_spanish(name)

    def _generate_peruvian_cultural(self, category: str) -> str:
        """Generate names with strong Peruvian/Andean cultural resonance."""
        strategies = [
            # Peruvian prefix + Spanish suffix
            lambda: random.choice(self.peruvian_prefixes) + random.choice(self.spanish_suffixes[:8]),  # Use Spanish endings

            # Peruvian prefix + diminutive (very Peruvian!)
            lambda: random.choice(self.peruvian_prefixes) + random.choice(['ito', 'ita', 'illo', 'illa']),

            # Peruvian element + word root
            lambda: random.choice(self.peruvian_prefixes) + self._get_word_root(category),

            # Two Peruvian elements
            lambda: random.choice(self.peruvian_prefixes) + random.choice(self.peruvian_prefixes),

            # Andean-style: use Quechua-like sounds
            lambda: self._generate_quechua_style(),
        ]

        name = random.choice(strategies)()
        return self._capitalize_spanish(name)

    def _generate_modern_spanish(self, category: str) -> str:
        """Generate modern, tech-friendly names that still sound Spanish."""
        # Use tech/modern suffixes
        modern_suffixes = ['tech', 'tek', 'lab', 'hub', 'app', 'net', 'pro', 'plus', 'io', 'ia']

        strategies = [
            # Spanish root + modern suffix
            lambda: self._get_word_root(category) + random.choice(modern_suffixes),

            # Common syllable + modern suffix
            lambda: random.choice(self.common_syllables) + random.choice(modern_suffixes),

            # Short syllabic + modern ending
            lambda: self._create_short_spanish_word() + random.choice(modern_suffixes),

            # Cluster-based modern name
            lambda: random.choice(self.clusters) + random.choice(self.vowels) + random.choice(modern_suffixes),
        ]

        name = random.choice(strategies)()
        return self._capitalize_spanish(name)

    def _generate_quechua_style(self) -> str:
        """Generate Quechua-influenced names (Andean phonetics)."""
        # Quechua prefers: CV pattern, uses q/k, w, y
        quechua_consonants = ['k', 'q', 'p', 't', 'ch', 's', 'l', 'll', 'r', 'w', 'y', 'm', 'n']
        quechua_vowels = ['a', 'i', 'u']

        length = random.randint(2, 3)  # 2-3 syllables
        name = ""

        for _ in range(length):
            # CV pattern (most common in Quechua)
            name += random.choice(quechua_consonants) + random.choice(quechua_vowels)

        return name

    def _create_spanish_syllable(self) -> str:
        """Create a syllable using Spanish phonetic patterns."""
        pattern = random.choice(self.syllable_patterns)
        syllable = ""

        for char_type in pattern:
            if char_type == 'C':
                # Use cluster 20% of the time, single consonant 80%
                if random.random() < 0.2:
                    syllable += random.choice(self.clusters)
                else:
                    syllable += random.choice(self.consonants)
            elif char_type == 'V':
                syllable += random.choice(self.vowels)

        return syllable

    def _create_short_spanish_word(self) -> str:
        """Create a short (3-5 letter) Spanish-sounding word."""
        length = random.randint(3, 5)
        word = ""

        # Favor CV pattern
        while len(word) < length:
            if len(word) == 0 or word[-1] in self.consonants:
                word += random.choice(self.vowels)
            else:
                word += random.choice(self.consonants)

        return word[:length]

    def _get_word_root(self, category: str) -> str:
        """Get a culturally-appropriate word root for the category."""
        if category in self.word_roots:
            return random.choice(self.word_roots[category])
        else:
            # Default to general evocative roots
            all_roots = []
            for roots_list in self.word_roots.values():
                all_roots.extend(roots_list)
            return random.choice(all_roots)

    def _capitalize_spanish(self, name: str) -> str:
        """Capitalize name according to Spanish conventions."""
        if not name:
            return name

        # Standard: capitalize first letter only
        return name[0].upper() + name[1:].lower()

    def _is_valid_spanish_name(self, name: str, min_length: int, max_length: int) -> bool:
        """Validate name for Spanish/Peruvian appropriateness."""
        if not name or not (min_length <= len(name) <= max_length):
            return False

        name_lower = name.lower()

        # Check forbidden patterns (including offensive words)
        for pattern in self.forbidden:
            if pattern in name_lower:
                return False

        # Check for awkward consonant clusters
        for cluster in self.avoid_clusters:
            if cluster in name_lower:
                return False

        # Must contain at least one vowel
        if not any(v in name_lower for v in self.all_vowels):
            return False

        # Should start with a letter
        if not name[0].isalpha():
            return False

        # Avoid too many consecutive consonants (hard to pronounce in Spanish)
        if re.search(r'[^aeiou]{4,}', name_lower):
            return False

        # Spanish prefers names ending in vowels (70% rule)
        # But allow consonant endings for modern names
        # Not enforcing strictly

        # Check vowel ratio (Spanish is vowel-rich)
        vowel_count = sum(1 for c in name_lower if c in self.all_vowels)
        vowel_ratio = vowel_count / len(name)

        # Spanish typically has 40-50% vowels
        if vowel_ratio < 0.25 or vowel_ratio > 0.75:
            return False

        return True

    def generate_variations(self, base_name: str, count: int = 5) -> List[str]:
        """Generate Spanish-appropriate variations of a name."""
        variations = set()

        strategies = [
            # Add diminutive (very Peruvian!)
            lambda: base_name + random.choice(['ito', 'ita', 'illo', 'illa']),

            # Add Spanish suffix
            lambda: base_name + random.choice(self.spanish_suffixes),

            # Add Peruvian prefix
            lambda: random.choice(self.peruvian_prefixes) + base_name.lower(),

            # Modify ending to Spanish-friendly
            lambda: base_name[:-1] + random.choice(self.vowels) if len(base_name) > 2 else base_name,

            # Add Spanish cluster
            lambda: base_name + random.choice(self.clusters) + random.choice(self.vowels),

            # Append common syllable
            lambda: base_name + random.choice(self.common_syllables),
        ]

        attempts = 0
        while len(variations) < count and attempts < count * 10:
            attempts += 1
            variation = random.choice(strategies)()
            variation = self._capitalize_spanish(variation)

            if self._is_valid_spanish_name(variation, 3, 15) and variation != base_name:
                variations.add(variation)

        return list(variations)


# Helper function for easy import
def generate_spanish_names(
    count: int = 10,
    style: str = 'hybrid',
    category: str = 'general',
    cultural_weight: float = 0.3
) -> List[str]:
    """
    Quick function to generate Spanish/Peruvian brand names.

    Args:
        count: Number of names
        style: 'spanish_evocative', 'spanish_syllabic', 'peruvian_cultural',
               'modern_spanish', or 'hybrid'
        category: Business category
        cultural_weight: How Peruvian vs. general Spanish (0.0-1.0)

    Returns:
        List of culturally-appropriate brand names
    """
    generator = SpanishBrandNameGenerator()
    return generator.generate(
        count=count,
        style=style,
        category=category,
        cultural_weight=cultural_weight
    )
