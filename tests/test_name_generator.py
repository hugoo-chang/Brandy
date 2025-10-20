"""
Unit tests for BrandNameGenerator
"""

import pytest
from brandy.name_generator import BrandNameGenerator


class TestBrandNameGenerator:
    """Test cases for name generation."""

    @pytest.fixture
    def generator(self):
        """Create a generator instance."""
        return BrandNameGenerator()

    def test_generate_default(self, generator):
        """Test default name generation."""
        names = generator.generate()

        assert len(names) == 10
        assert all(isinstance(name, str) for name in names)
        assert all(len(name) >= 5 for name in names)
        assert all(len(name) <= 10 for name in names)

    def test_generate_custom_count(self, generator):
        """Test generation with custom count."""
        names = generator.generate(count=5)
        assert len(names) == 5

    def test_generate_custom_length(self, generator):
        """Test generation with custom length constraints."""
        names = generator.generate(min_length=6, max_length=8)

        assert all(6 <= len(name) <= 8 for name in names)

    def test_generate_evocative_style(self, generator):
        """Test evocative style generation."""
        names = generator.generate(count=5, style='evocative')

        assert len(names) == 5
        assert all(isinstance(name, str) for name in names)

    def test_generate_syllabic_style(self, generator):
        """Test syllabic style generation."""
        names = generator.generate(count=5, style='syllabic')

        assert len(names) == 5
        assert all(isinstance(name, str) for name in names)

    def test_generate_modern_style(self, generator):
        """Test modern style generation."""
        names = generator.generate(count=5, style='modern')

        assert len(names) == 5
        assert all(isinstance(name, str) for name in names)

    def test_generate_variations(self, generator):
        """Test variation generation."""
        base_name = "Nova"
        variations = generator.generate_variations(base_name, count=5)

        assert len(variations) <= 5
        assert all(isinstance(var, str) for var in variations)
        # Variations should be different from base
        assert all(var != base_name for var in variations)

    def test_name_capitalization(self, generator):
        """Test that generated names are properly capitalized."""
        names = generator.generate(count=5)

        assert all(name[0].isupper() for name in names)

    def test_forbidden_patterns_avoided(self, generator):
        """Test that forbidden patterns are not in generated names."""
        names = generator.generate(count=20)

        forbidden = ['super', 'mega', 'ultra', 'max', 'plus', 'pro', 'best']

        for name in names:
            name_lower = name.lower()
            assert not any(pattern in name_lower for pattern in forbidden)

    def test_names_have_vowels_and_consonants(self, generator):
        """Test that names have both vowels and consonants."""
        names = generator.generate(count=10)

        vowels = set('aeiou')
        consonants = set('bcdfghjklmnpqrstvwxyz')

        for name in names:
            name_lower = set(name.lower())
            assert len(name_lower & vowels) > 0, f"{name} has no vowels"
            assert len(name_lower & consonants) > 0, f"{name} has no consonants"
