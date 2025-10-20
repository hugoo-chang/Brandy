"""
Brand Name Generator Module

Generates distinctive brand names following INDECOPI guidelines.
Avoids generic, descriptive terms and ensures phonetic distinctiveness.
"""

import random
import re
from typing import List, Optional, Set
from .config import (
    DEFAULT_MIN_LENGTH,
    DEFAULT_MAX_LENGTH,
    VOWELS,
    CONSONANTS,
    SPANISH_SYLLABLE_PATTERNS,
    FORBIDDEN_PATTERNS
)


class BrandNameGenerator:
    """
    Generates distinctive, evocative brand names.
    """

    def __init__(self):
        self.vowels = VOWELS
        self.consonants = CONSONANTS
        self.syllable_patterns = SPANISH_SYLLABLE_PATTERNS
        self.forbidden_patterns = FORBIDDEN_PATTERNS

        # Common Spanish phoneme combinations that sound natural
        self.natural_consonant_clusters = [
            'bl', 'br', 'cl', 'cr', 'dr', 'fl', 'fr', 'gl', 'gr',
            'pl', 'pr', 'tr', 'ch', 'll', 'rr'
        ]

        # Prefix/suffix options for evocative names
        self.evocative_prefixes = [
            'avi', 'bri', 'cri', 'dra', 'evo', 'flo', 'glo', 'lumi',
            'nex', 'nova', 'ori', 'pix', 'qua', 'radi', 'soli', 'tera',
            'ultra', 'viva', 'zeni', 'aero', 'bio', 'eco'
        ]

        self.evocative_suffixes = [
            'ix', 'ex', 'on', 'ar', 'ia', 'io', 'us', 'is', 'os',
            'ify', 'ize', 'tek', 'lab', 'hub', 'link', 'wave', 'zone'
        ]

    def generate(
        self,
        count: int = 10,
        min_length: int = DEFAULT_MIN_LENGTH,
        max_length: int = DEFAULT_MAX_LENGTH,
        category: str = 'general',
        style: str = 'evocative'
    ) -> List[str]:
        """
        Generate multiple brand names.

        Args:
            count: Number of names to generate
            min_length: Minimum name length
            max_length: Maximum name length
            category: Business category (for context)
            style: Generation style ('evocative', 'syllabic', 'hybrid', 'modern')

        Returns:
            List of generated brand names
        """
        names = set()
        attempts = 0
        max_attempts = count * 10  # Prevent infinite loops

        while len(names) < count and attempts < max_attempts:
            attempts += 1

            if style == 'evocative':
                name = self._generate_evocative()
            elif style == 'syllabic':
                name = self._generate_syllabic(min_length, max_length)
            elif style == 'modern':
                name = self._generate_modern()
            else:  # hybrid
                # Mix different styles
                method = random.choice([
                    self._generate_evocative,
                    self._generate_syllabic,
                    self._generate_modern
                ])
                if method == self._generate_syllabic:
                    name = method(min_length, max_length)
                else:
                    name = method()

            # Validate name
            if self._is_valid_name(name, min_length, max_length):
                names.add(name)

        return list(names)

    def _generate_syllabic(self, min_length: int, max_length: int) -> str:
        """
        Generate name using syllable patterns.
        """
        target_length = random.randint(min_length, max_length)
        name = ""

        while len(name) < target_length:
            # Choose a syllable pattern
            pattern = random.choice(self.syllable_patterns)

            syllable = ""
            for char_type in pattern:
                if char_type == 'C':
                    # Occasionally use consonant clusters
                    if random.random() < 0.2 and len(syllable) == 0:
                        syllable += random.choice(self.natural_consonant_clusters)
                    else:
                        syllable += random.choice(self.consonants)
                elif char_type == 'V':
                    syllable += random.choice(self.vowels)

            name += syllable

        # Trim to desired length
        name = name[:target_length]

        # Capitalize first letter
        return name.capitalize()

    def _generate_evocative(self) -> str:
        """
        Generate evocative name using meaningful prefixes/suffixes.
        """
        strategies = [
            # Prefix + Suffix
            lambda: random.choice(self.evocative_prefixes) + random.choice(self.evocative_suffixes),
            # Prefix + syllable
            lambda: random.choice(self.evocative_prefixes) + self._random_syllable(),
            # Syllable + Suffix
            lambda: self._random_syllable() + random.choice(self.evocative_suffixes),
            # Two prefixes combined
            lambda: random.choice(self.evocative_prefixes) + random.choice(self.evocative_prefixes[5:]),
        ]

        name = random.choice(strategies)()
        return name.capitalize()

    def _generate_modern(self) -> str:
        """
        Generate modern tech-style names (short, punchy, memorable).
        """
        strategies = [
            # Short vowel removal style (like Flickr, Tumblr)
            lambda: self._create_vowel_dropped(),
            # Blend two syllables with shared sound
            lambda: self._create_blend(),
            # Single syllable + 'y' ending
            lambda: self._random_syllable() + 'y',
            # Doubled letter for impact
            lambda: self._create_doubled(),
        ]

        name = random.choice(strategies)()
        return name.capitalize()

    def _random_syllable(self) -> str:
        """Generate a random syllable."""
        pattern = random.choice(self.syllable_patterns)
        syllable = ""

        for char_type in pattern:
            if char_type == 'C':
                syllable += random.choice(self.consonants)
            elif char_type == 'V':
                syllable += random.choice(self.vowels)

        return syllable

    def _create_vowel_dropped(self) -> str:
        """Create name with strategic vowel removal."""
        base = self._random_syllable() + self._random_syllable()
        # Remove some vowels but keep at least one
        vowels_in_name = [i for i, c in enumerate(base) if c in self.vowels]

        if len(vowels_in_name) > 1:
            # Remove a vowel
            to_remove = random.choice(vowels_in_name[1:])
            base = base[:to_remove] + base[to_remove + 1:]

        return base

    def _create_blend(self) -> str:
        """Blend two syllables with overlapping sounds."""
        syl1 = self._random_syllable()
        syl2 = self._random_syllable()

        # Try to find overlap
        for i in range(1, min(len(syl1), len(syl2)) + 1):
            if syl1[-i:] == syl2[:i]:
                return syl1 + syl2[i:]

        # No overlap, just concatenate
        return syl1 + syl2

    def _create_doubled(self) -> str:
        """Create name with doubled consonant for impact."""
        syllable = self._random_syllable()
        if syllable and syllable[0] in self.consonants:
            return syllable[0] + syllable

        return syllable + syllable[-1] if syllable else self._random_syllable()

    def _is_valid_name(
        self,
        name: str,
        min_length: int,
        max_length: int
    ) -> bool:
        """
        Validate that name meets INDECOPI guidelines.
        """
        # Check length
        if not (min_length <= len(name) <= max_length):
            return False

        # Check if name contains forbidden patterns
        name_lower = name.lower()
        for pattern in self.forbidden_patterns:
            if pattern in name_lower:
                return False

        # Must contain at least one vowel
        if not any(v in name_lower for v in self.vowels):
            return False

        # Must contain at least one consonant
        if not any(c in name_lower for c in self.consonants):
            return False

        # Avoid too many consecutive consonants (hard to pronounce)
        if re.search(r'[^aeiou]{4,}', name_lower):
            return False

        # Avoid too many consecutive vowels
        if re.search(r'[aeiou]{4,}', name_lower):
            return False

        # Must start with a letter
        if not name[0].isalpha():
            return False

        # Check if it looks too generic (all vowels or all consonants)
        vowel_ratio = sum(1 for c in name_lower if c in self.vowels) / len(name)
        if vowel_ratio < 0.2 or vowel_ratio > 0.8:
            return False

        return True

    def generate_variations(self, base_name: str, count: int = 5) -> List[str]:
        """
        Generate variations of a base name.

        Args:
            base_name: Starting name
            count: Number of variations to generate

        Returns:
            List of name variations
        """
        variations = set()

        strategies = [
            lambda: base_name + random.choice(self.evocative_suffixes),
            lambda: random.choice(self.evocative_prefixes) + base_name.lower(),
            lambda: base_name + random.choice(['i', 'o', 'a', 'e']),
            lambda: base_name[:-1] + random.choice(self.vowels) if len(base_name) > 2 else base_name,
            lambda: self._double_letter(base_name),
        ]

        attempts = 0
        while len(variations) < count and attempts < count * 5:
            attempts += 1
            variation = random.choice(strategies)()

            if variation and self._is_valid_name(variation, 3, 15):
                variations.add(variation.capitalize())

        return list(variations)

    def _double_letter(self, name: str) -> str:
        """Double a consonant in the name."""
        consonant_positions = [
            i for i, c in enumerate(name.lower())
            if c in self.consonants
        ]

        if consonant_positions:
            pos = random.choice(consonant_positions)
            return name[:pos + 1] + name[pos:]

        return name
