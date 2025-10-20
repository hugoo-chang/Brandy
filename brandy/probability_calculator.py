"""
Registration Probability Calculator Module

Calculates the likelihood of successful trademark registration
based on multiple factors following INDECOPI guidelines.
"""

from typing import Dict, List, Optional
from .similarity_analyzer import SimilarityAnalyzer
from .config import PROBABILITY_WEIGHTS, FORBIDDEN_PATTERNS


class ProbabilityCalculator:
    """
    Calculates trademark registration probability.
    """

    def __init__(self):
        self.analyzer = SimilarityAnalyzer()
        self.weights = PROBABILITY_WEIGHTS

    def calculate(
        self,
        name: str,
        existing_trademarks: List[Dict],
        category: Optional[int] = None
    ) -> Dict:
        """
        Calculate registration probability for a brand name.

        Args:
            name: Proposed brand name
            existing_trademarks: List of existing trademark records from INDECOPI
            category: NICE classification number (optional)

        Returns:
            Dictionary with probability score and detailed analysis
        """
        # Calculate individual scores
        distinctiveness_score = self._calculate_distinctiveness(name)
        phonetic_score = self._calculate_phonetic_conflicts(name, existing_trademarks)
        spelling_score = self._calculate_spelling_conflicts(name, existing_trademarks)
        category_score = self._calculate_category_overlap(
            name, existing_trademarks, category
        )

        # Calculate weighted probability
        probability = (
            distinctiveness_score * self.weights['distinctiveness'] +
            phonetic_score * self.weights['phonetic_conflicts'] +
            spelling_score * self.weights['spelling_similarity'] +
            category_score * self.weights['category_overlap']
        )

        # Determine risk level
        risk_level = self._determine_risk_level(probability)

        # Find most similar existing marks
        conflicts = self._find_top_conflicts(name, existing_trademarks, top_n=5)

        return {
            'name': name,
            'probability': round(probability, 2),
            'risk_level': risk_level,
            'scores': {
                'distinctiveness': round(distinctiveness_score, 2),
                'phonetic_conflicts': round(phonetic_score, 2),
                'spelling_similarity': round(spelling_score, 2),
                'category_overlap': round(category_score, 2),
            },
            'top_conflicts': conflicts,
            'recommendation': self._generate_recommendation(
                probability, risk_level, conflicts
            )
        }

    def _calculate_distinctiveness(self, name: str) -> float:
        """
        Calculate distinctiveness score (0-100).

        Higher scores indicate more distinctive names.
        Penalizes generic, descriptive, or common patterns.
        """
        score = 100.0
        name_lower = name.lower()

        # Check for forbidden patterns (generic/descriptive terms)
        for pattern in FORBIDDEN_PATTERNS:
            if pattern in name_lower:
                score -= 30  # Heavy penalty for forbidden patterns

        # Check length (very short or very long names may be less distinctive)
        if len(name) < 4:
            score -= 15
        elif len(name) > 12:
            score -= 10

        # Check for common word patterns
        common_endings = ['ing', 'tion', 'ness', 'ment', 'able', 'ible']
        for ending in common_endings:
            if name_lower.endswith(ending):
                score -= 10
                break

        # Check if name is too simple (alternating consonant-vowel)
        if self._is_too_simple(name):
            score -= 15

        # Check uniqueness of character combinations
        uniqueness_bonus = self._calculate_uniqueness(name)
        score += uniqueness_bonus

        return max(0.0, min(100.0, score))

    def _calculate_phonetic_conflicts(
        self,
        name: str,
        existing_trademarks: List[Dict]
    ) -> float:
        """
        Calculate score based on phonetic conflicts (0-100).

        Higher scores = fewer conflicts (better).
        """
        if not existing_trademarks:
            return 100.0

        # Extract just the names from trademark records
        existing_names = [
            tm.get('denomination', '') or tm.get('name', '')
            for tm in existing_trademarks
        ]
        existing_names = [n for n in existing_names if n]  # Filter empty

        if not existing_names:
            return 100.0

        # Find conflicts
        conflicts = self.analyzer.batch_analyze(
            name,
            existing_names,
            threshold=0.60  # Lower threshold to catch more potential conflicts
        )

        # Calculate score based on number and severity of conflicts
        if not conflicts:
            return 100.0

        # Penalize based on highest similarity
        max_similarity = max(c['phonetic_score'] for c in conflicts)

        # Score decreases with similarity
        if max_similarity >= 0.90:
            score = 0.0  # Extremely similar - likely rejection
        elif max_similarity >= 0.80:
            score = 20.0  # Very similar - high risk
        elif max_similarity >= 0.70:
            score = 50.0  # Similar - medium risk
        elif max_similarity >= 0.60:
            score = 75.0  # Somewhat similar - low risk
        else:
            score = 100.0  # Not similar

        # Additional penalty for multiple conflicts
        conflict_penalty = min(30, len(conflicts) * 5)
        score -= conflict_penalty

        return max(0.0, score)

    def _calculate_spelling_conflicts(
        self,
        name: str,
        existing_trademarks: List[Dict]
    ) -> float:
        """
        Calculate score based on spelling similarity (0-100).

        Higher scores = less similarity (better).
        """
        if not existing_trademarks:
            return 100.0

        existing_names = [
            tm.get('denomination', '') or tm.get('name', '')
            for tm in existing_trademarks
        ]
        existing_names = [n for n in existing_names if n]

        if not existing_names:
            return 100.0

        # Find max spelling similarity
        max_similarity = 0.0
        for existing_name in existing_names:
            analysis = self.analyzer.analyze(name, existing_name)
            max_similarity = max(max_similarity, analysis['spelling_score'])

        # Convert similarity to score (inverse relationship)
        if max_similarity >= 0.95:
            score = 0.0
        elif max_similarity >= 0.85:
            score = 25.0
        elif max_similarity >= 0.75:
            score = 50.0
        elif max_similarity >= 0.65:
            score = 75.0
        else:
            score = 100.0

        return score

    def _calculate_category_overlap(
        self,
        name: str,
        existing_trademarks: List[Dict],
        target_category: Optional[int]
    ) -> float:
        """
        Calculate score based on category overlap (0-100).

        Higher scores = less overlap in same category (better).
        """
        if not target_category or not existing_trademarks:
            return 100.0

        # Count similar names in same category
        same_category_conflicts = []

        for tm in existing_trademarks:
            tm_class = tm.get('class', tm.get('category', ''))

            # Parse class/category (might be string or int)
            try:
                if isinstance(tm_class, str):
                    tm_class_num = int(tm_class.split()[0])  # Handle "35 - Services"
                else:
                    tm_class_num = int(tm_class)

                if tm_class_num == target_category:
                    tm_name = tm.get('denomination', tm.get('name', ''))
                    if tm_name:
                        analysis = self.analyzer.analyze(name, tm_name)
                        if analysis['overall_score'] >= 0.60:
                            same_category_conflicts.append(analysis)
            except (ValueError, AttributeError):
                continue

        # Score based on same-category conflicts
        if not same_category_conflicts:
            return 100.0

        # Heavy penalty for conflicts in same category
        num_conflicts = len(same_category_conflicts)
        max_similarity = max(c['overall_score'] for c in same_category_conflicts)

        score = 100.0 - (num_conflicts * 15) - (max_similarity * 50)

        return max(0.0, score)

    def _is_too_simple(self, name: str) -> bool:
        """Check if name follows overly simple patterns."""
        name_lower = name.lower()
        vowels = 'aeiou'

        # Check for strict alternating consonant-vowel pattern
        if len(name) < 4:
            return False

        alternating = True
        for i in range(len(name_lower) - 1):
            curr_is_vowel = name_lower[i] in vowels
            next_is_vowel = name_lower[i + 1] in vowels

            if curr_is_vowel == next_is_vowel:
                alternating = False
                break

        return alternating

    def _calculate_uniqueness(self, name: str) -> float:
        """
        Calculate uniqueness bonus based on uncommon character combinations.
        """
        bonus = 0.0

        # Uncommon starting letters
        if name[0].lower() in ['q', 'x', 'z', 'k']:
            bonus += 5.0

        # Contains uncommon combinations
        uncommon_pairs = ['qu', 'zh', 'kh', 'ph', 'th', 'ch']
        for pair in uncommon_pairs:
            if pair in name.lower():
                bonus += 3.0

        return min(15.0, bonus)  # Cap at 15

    def _find_top_conflicts(
        self,
        name: str,
        existing_trademarks: List[Dict],
        top_n: int = 5
    ) -> List[Dict]:
        """Find the most similar existing trademarks."""
        if not existing_trademarks:
            return []

        existing_names = [
            tm.get('denomination', '') or tm.get('name', '')
            for tm in existing_trademarks
        ]

        # Create a mapping of names to full trademark data
        name_to_tm = {
            (tm.get('denomination', '') or tm.get('name', '')): tm
            for tm in existing_trademarks
        }

        # Get top matches
        top_matches = self.analyzer.find_best_matches(
            name,
            [n for n in existing_names if n],
            top_n=top_n
        )

        # Enrich with trademark data
        conflicts = []
        for existing_name, similarity in top_matches:
            if similarity >= 0.50:  # Only include significant similarities
                tm_data = name_to_tm.get(existing_name, {})
                conflicts.append({
                    'name': existing_name,
                    'similarity': round(similarity, 3),
                    'holder': tm_data.get('holder', 'Unknown'),
                    'class': tm_data.get('class', tm_data.get('category', 'Unknown')),
                    'status': tm_data.get('status', 'Unknown'),
                })

        return conflicts

    def _determine_risk_level(self, probability: float) -> str:
        """Determine risk level based on probability score."""
        if probability >= 80:
            return "LOW"
        elif probability >= 60:
            return "MEDIUM"
        elif probability >= 40:
            return "HIGH"
        else:
            return "VERY HIGH"

    def _generate_recommendation(
        self,
        probability: float,
        risk_level: str,
        conflicts: List[Dict]
    ) -> str:
        """Generate human-readable recommendation."""
        if probability >= 80:
            return (
                "Excellent! This name has a high probability of successful registration. "
                "Few or no conflicts detected."
            )
        elif probability >= 60:
            return (
                "Good potential, but there are some similar existing marks. "
                "Consider reviewing the conflicts and consulting with an IP attorney."
            )
        elif probability >= 40:
            return (
                "Moderate risk. Several similar marks exist. "
                "Strongly recommend consulting with an IP attorney before filing."
            )
        else:
            return (
                "High risk of rejection. This name is very similar to existing marks. "
                "Consider choosing a different name or consulting with an IP attorney."
            )

    def batch_calculate(
        self,
        names: List[str],
        existing_trademarks: List[Dict],
        category: Optional[int] = None
    ) -> List[Dict]:
        """
        Calculate probabilities for multiple names.

        Returns list sorted by probability (highest first).
        """
        results = []

        for name in names:
            result = self.calculate(name, existing_trademarks, category)
            results.append(result)

        # Sort by probability (highest first)
        results.sort(key=lambda x: x['probability'], reverse=True)

        return results
