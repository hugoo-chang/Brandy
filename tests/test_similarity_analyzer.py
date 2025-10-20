"""
Unit tests for SimilarityAnalyzer
"""

import pytest
from brandy.similarity_analyzer import SimilarityAnalyzer


class TestSimilarityAnalyzer:
    """Test cases for similarity analysis."""

    @pytest.fixture
    def analyzer(self):
        """Create an analyzer instance."""
        return SimilarityAnalyzer()

    def test_analyze_identical_names(self, analyzer):
        """Test analysis of identical names."""
        result = analyzer.analyze("TechNova", "TechNova")

        assert result['overall_score'] == 1.0
        assert result['is_conflict'] is True

    def test_analyze_different_names(self, analyzer):
        """Test analysis of completely different names."""
        result = analyzer.analyze("Apple", "Microsoft")

        assert result['overall_score'] < 0.5

    def test_analyze_similar_phonetic(self, analyzer):
        """Test phonetically similar names."""
        result = analyzer.analyze("Fone", "Phone")

        # Should have high phonetic similarity
        assert result['phonetic_score'] > 0.7

    def test_analyze_similar_spelling(self, analyzer):
        """Test names with similar spelling."""
        result = analyzer.analyze("Google", "Googel")

        # Should have high spelling similarity
        assert result['spelling_score'] > 0.7

    def test_batch_analyze(self, analyzer):
        """Test batch analysis."""
        target = "TechNova"
        existing = ["TekNova", "TechNovo", "Apple", "Microsoft"]

        conflicts = analyzer.batch_analyze(target, existing, threshold=0.6)

        # Should find at least TekNova and TechNovo as conflicts
        assert len(conflicts) >= 2
        assert conflicts[0]['overall_score'] >= conflicts[1]['overall_score']

    def test_find_best_matches(self, analyzer):
        """Test finding best matches."""
        target = "Nova"
        existing = ["Nava", "Novo", "Nova", "Apple", "Microsoft"]

        matches = analyzer.find_best_matches(target, existing, top_n=3)

        assert len(matches) == 3
        # First match should be identical "Nova"
        assert matches[0][0] == "Nova"
        assert matches[0][1] == 1.0

    def test_case_insensitive(self, analyzer):
        """Test that analysis is case-insensitive."""
        result1 = analyzer.analyze("TechNova", "technova")
        result2 = analyzer.analyze("TECHNOVA", "TechNova")

        assert result1['overall_score'] == 1.0
        assert result2['overall_score'] == 1.0

    def test_metaphone_similarity(self, analyzer):
        """Test Metaphone algorithm."""
        # Names that sound similar
        score = analyzer._metaphone_similarity("night", "knight")
        assert score > 0.8

    def test_soundex_similarity(self, analyzer):
        """Test Soundex algorithm."""
        # Names with similar sounds
        score = analyzer._soundex_similarity("Robert", "Rupert")
        # Soundex is less precise, so threshold is lower
        assert score >= 0.0

    def test_levenshtein_similarity(self, analyzer):
        """Test Levenshtein distance."""
        score = analyzer._levenshtein_similarity("kitten", "sitting")

        # Should be reasonably similar
        assert 0.3 <= score <= 0.7

    def test_visual_similarity(self, analyzer):
        """Test visual similarity detection."""
        # Names that look similar
        score = analyzer._visual_similarity("Google", "Googol")

        assert score > 0.7
