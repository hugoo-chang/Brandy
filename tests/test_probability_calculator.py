"""
Unit tests for ProbabilityCalculator
"""

import pytest
from brandy.probability_calculator import ProbabilityCalculator


class TestProbabilityCalculator:
    """Test cases for probability calculation."""

    @pytest.fixture
    def calculator(self):
        """Create a calculator instance."""
        return ProbabilityCalculator()

    @pytest.fixture
    def sample_trademarks(self):
        """Sample trademark data for testing."""
        return [
            {
                'denomination': 'TechNova',
                'holder': 'Tech Corp',
                'class': '9',
                'status': 'Registered'
            },
            {
                'denomination': 'NovaTech',
                'holder': 'Nova Inc',
                'class': '42',
                'status': 'Registered'
            },
            {
                'denomination': 'Apple',
                'holder': 'Apple Inc',
                'class': '9',
                'status': 'Registered'
            },
        ]

    def test_calculate_with_no_conflicts(self, calculator):
        """Test calculation with no existing trademarks."""
        result = calculator.calculate("UniqueNameXYZ", [])

        assert result['probability'] >= 80
        assert result['risk_level'] == "LOW"
        assert len(result['top_conflicts']) == 0

    def test_calculate_with_conflicts(self, calculator, sample_trademarks):
        """Test calculation with conflicting trademarks."""
        result = calculator.calculate("TechNovo", sample_trademarks)

        # Should detect similarity to TechNova
        assert result['probability'] < 100
        assert len(result['top_conflicts']) > 0

    def test_calculate_distinctive_name(self, calculator, sample_trademarks):
        """Test calculation for distinctive name."""
        result = calculator.calculate("ZyphixFlow", sample_trademarks)

        # Distinctive name should score well
        assert result['scores']['distinctiveness'] >= 70

    def test_calculate_generic_name(self, calculator):
        """Test calculation for generic name."""
        result = calculator.calculate("SuperTech", [])

        # Generic name should have lower distinctiveness
        assert result['scores']['distinctiveness'] < 80

    def test_risk_levels(self, calculator):
        """Test risk level determination."""
        assert calculator._determine_risk_level(85) == "LOW"
        assert calculator._determine_risk_level(70) == "MEDIUM"
        assert calculator._determine_risk_level(50) == "HIGH"
        assert calculator._determine_risk_level(30) == "VERY HIGH"

    def test_batch_calculate(self, calculator, sample_trademarks):
        """Test batch calculation."""
        names = ["Nova", "TechFlow", "AppleX"]

        results = calculator.batch_calculate(names, sample_trademarks)

        assert len(results) == 3
        # Should be sorted by probability (highest first)
        assert results[0]['probability'] >= results[1]['probability']
        assert results[1]['probability'] >= results[2]['probability']

    def test_category_overlap(self, calculator, sample_trademarks):
        """Test category overlap detection."""
        # Same name, same category should have lower score
        result = calculator.calculate("TechNova", sample_trademarks, category=9)

        # Different category should have higher score
        result2 = calculator.calculate("TechNova", sample_trademarks, category=35)

        # Same category should have more penalty
        assert result['scores']['category_overlap'] <= result2['scores']['category_overlap']

    def test_find_top_conflicts(self, calculator, sample_trademarks):
        """Test finding top conflicts."""
        conflicts = calculator._find_top_conflicts("TechNova", sample_trademarks, top_n=2)

        # Should find TechNova itself as top conflict
        assert len(conflicts) > 0
        assert conflicts[0]['similarity'] >= 0.90  # Nearly identical

    def test_distinctiveness_forbidden_patterns(self, calculator):
        """Test that forbidden patterns reduce distinctiveness."""
        score_good = calculator._calculate_distinctiveness("ZyphixFlow")
        score_bad = calculator._calculate_distinctiveness("SuperMax")

        assert score_good > score_bad

    def test_recommendation_generation(self, calculator):
        """Test recommendation text generation."""
        rec_high = calculator._generate_recommendation(85, "LOW", [])
        rec_low = calculator._generate_recommendation(30, "VERY HIGH", [])

        assert "high probability" in rec_high.lower() or "excellent" in rec_high.lower()
        assert "risk" in rec_low.lower() or "consider" in rec_low.lower()
