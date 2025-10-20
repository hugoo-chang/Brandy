"""
Brandy - INDECOPI Brand Name Generator

An intelligent brand name generator that complies with INDECOPI guidelines.
"""

from .name_generator import BrandNameGenerator
from .similarity_analyzer import SimilarityAnalyzer
from .probability_calculator import ProbabilityCalculator
from .indecopi_scraper import IndecopiScraper

__version__ = "0.1.0"
__all__ = [
    "BrandNameGenerator",
    "SimilarityAnalyzer",
    "ProbabilityCalculator",
    "IndecopiScraper",
]
