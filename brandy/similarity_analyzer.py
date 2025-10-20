"""
Similarity Analyzer Module

Performs phonetic and spelling similarity analysis between brand names.
Uses multiple algorithms to detect potential trademark conflicts.
"""

import jellyfish
import Levenshtein
from typing import Dict, List, Tuple
from .config import (
    PHONETIC_ALGORITHMS,
    PHONETIC_SIMILARITY_THRESHOLD,
    SPELLING_SIMILARITY_THRESHOLD
)


class SimilarityAnalyzer:
    """
    Analyzes phonetic and spelling similarity between brand names.
    """

    def __init__(self):
        self.phonetic_weights = PHONETIC_ALGORITHMS
        self.phonetic_threshold = PHONETIC_SIMILARITY_THRESHOLD
        self.spelling_threshold = SPELLING_SIMILARITY_THRESHOLD

    def analyze(self, name1: str, name2: str) -> Dict[str, any]:
        """
        Perform comprehensive similarity analysis between two names.

        Args:
            name1: First brand name
            name2: Second brand name

        Returns:
            Dictionary containing similarity scores and analysis
        """
        # Normalize names
        n1 = self._normalize(name1)
        n2 = self._normalize(name2)

        # Calculate different similarity metrics
        phonetic_score = self._phonetic_similarity(n1, n2)
        spelling_score = self._spelling_similarity(n1, n2)
        visual_score = self._visual_similarity(n1, n2)

        # Overall similarity (weighted average)
        overall_score = (
            phonetic_score * 0.40 +
            spelling_score * 0.40 +
            visual_score * 0.20
        )

        # Determine if there's a conflict
        is_conflict = (
            phonetic_score >= self.phonetic_threshold or
            spelling_score >= self.spelling_threshold
        )

        return {
            'phonetic_score': round(phonetic_score, 3),
            'spelling_score': round(spelling_score, 3),
            'visual_score': round(visual_score, 3),
            'overall_score': round(overall_score, 3),
            'is_conflict': is_conflict,
            'details': {
                'metaphone': self._metaphone_similarity(n1, n2),
                'soundex': self._soundex_similarity(n1, n2),
                'nysiis': self._nysiis_similarity(n1, n2),
                'levenshtein': self._levenshtein_similarity(n1, n2),
            }
        }

    def _normalize(self, name: str) -> str:
        """Normalize name for comparison."""
        return name.lower().strip()

    def _phonetic_similarity(self, name1: str, name2: str) -> float:
        """
        Calculate weighted phonetic similarity using multiple algorithms.
        """
        scores = {
            'metaphone': self._metaphone_similarity(name1, name2),
            'soundex': self._soundex_similarity(name1, name2),
            'nysiis': self._nysiis_similarity(name1, name2),
            'match_rating': self._match_rating_similarity(name1, name2),
        }

        # Weighted average
        weighted_score = sum(
            scores[algo] * weight
            for algo, weight in self.phonetic_weights.items()
        )

        return weighted_score

    def _metaphone_similarity(self, name1: str, name2: str) -> float:
        """Compare using Metaphone algorithm."""
        try:
            m1 = jellyfish.metaphone(name1)
            m2 = jellyfish.metaphone(name2)
            if not m1 or not m2:
                return 0.0
            return 1.0 if m1 == m2 else self._levenshtein_similarity(m1, m2)
        except:
            return 0.0

    def _soundex_similarity(self, name1: str, name2: str) -> float:
        """Compare using Soundex algorithm."""
        try:
            s1 = jellyfish.soundex(name1)
            s2 = jellyfish.soundex(name2)
            if not s1 or not s2:
                return 0.0
            return 1.0 if s1 == s2 else 0.0
        except:
            return 0.0

    def _nysiis_similarity(self, name1: str, name2: str) -> float:
        """Compare using NYSIIS algorithm."""
        try:
            n1 = jellyfish.nysiis(name1)
            n2 = jellyfish.nysiis(name2)
            if not n1 or not n2:
                return 0.0
            return 1.0 if n1 == n2 else self._levenshtein_similarity(n1, n2)
        except:
            return 0.0

    def _match_rating_similarity(self, name1: str, name2: str) -> float:
        """Compare using Match Rating Codex."""
        try:
            comparison = jellyfish.match_rating_comparison(name1, name2)
            return 1.0 if comparison else 0.0
        except:
            return 0.0

    def _spelling_similarity(self, name1: str, name2: str) -> float:
        """
        Calculate spelling similarity using multiple string distance metrics.
        """
        lev_sim = self._levenshtein_similarity(name1, name2)
        jaro_sim = self._jaro_winkler_similarity(name1, name2)

        # Average of multiple metrics
        return (lev_sim * 0.6 + jaro_sim * 0.4)

    def _levenshtein_similarity(self, name1: str, name2: str) -> float:
        """Calculate Levenshtein distance-based similarity."""
        if not name1 or not name2:
            return 0.0

        distance = Levenshtein.distance(name1, name2)
        max_len = max(len(name1), len(name2))

        if max_len == 0:
            return 1.0

        similarity = 1.0 - (distance / max_len)
        return max(0.0, similarity)

    def _jaro_winkler_similarity(self, name1: str, name2: str) -> float:
        """Calculate Jaro-Winkler similarity."""
        try:
            return jellyfish.jaro_winkler_similarity(name1, name2)
        except:
            return 0.0

    def _visual_similarity(self, name1: str, name2: str) -> float:
        """
        Estimate visual similarity based on character patterns.
        Checks for similar starting/ending patterns and length.
        """
        if not name1 or not name2:
            return 0.0

        score = 0.0

        # Length similarity
        len_diff = abs(len(name1) - len(name2))
        max_len = max(len(name1), len(name2))
        len_similarity = 1.0 - (len_diff / max_len) if max_len > 0 else 0.0
        score += len_similarity * 0.3

        # Starting characters similarity
        prefix_len = min(3, len(name1), len(name2))
        if prefix_len > 0:
            prefix_match = sum(
                1 for i in range(prefix_len)
                if name1[i] == name2[i]
            ) / prefix_len
            score += prefix_match * 0.4

        # Ending characters similarity
        suffix_len = min(2, len(name1), len(name2))
        if suffix_len > 0:
            suffix_match = sum(
                1 for i in range(1, suffix_len + 1)
                if name1[-i] == name2[-i]
            ) / suffix_len
            score += suffix_match * 0.3

        return min(1.0, score)

    def batch_analyze(
        self,
        target_name: str,
        existing_names: List[str],
        threshold: float = None
    ) -> List[Dict]:
        """
        Analyze target name against a list of existing names.

        Args:
            target_name: Name to check
            existing_names: List of existing trademark names
            threshold: Minimum similarity score to include (default: phonetic threshold)

        Returns:
            List of conflicts sorted by overall similarity (highest first)
        """
        if threshold is None:
            threshold = self.phonetic_threshold

        conflicts = []

        for existing_name in existing_names:
            analysis = self.analyze(target_name, existing_name)

            if analysis['overall_score'] >= threshold:
                conflicts.append({
                    'existing_name': existing_name,
                    **analysis
                })

        # Sort by overall score (highest first)
        conflicts.sort(key=lambda x: x['overall_score'], reverse=True)

        return conflicts

    def find_best_matches(
        self,
        target_name: str,
        existing_names: List[str],
        top_n: int = 10
    ) -> List[Tuple[str, float]]:
        """
        Find the top N most similar names.

        Args:
            target_name: Name to check
            existing_names: List of existing names
            top_n: Number of top matches to return

        Returns:
            List of tuples (name, similarity_score)
        """
        similarities = []

        for existing_name in existing_names:
            analysis = self.analyze(target_name, existing_name)
            similarities.append((existing_name, analysis['overall_score']))

        # Sort by similarity (highest first) and return top N
        similarities.sort(key=lambda x: x[1], reverse=True)
        return similarities[:top_n]
