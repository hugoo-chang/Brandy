"""
Brandy - INDECOPI Brand Name Generator

An intelligent brand name generator that complies with INDECOPI guidelines.
"""

from .name_generator import BrandNameGenerator
from .spanish_name_generator import SpanishBrandNameGenerator, generate_spanish_names
from .similarity_analyzer import SimilarityAnalyzer
from .probability_calculator import ProbabilityCalculator
from .indecopi_scraper import IndecopiScraper

__version__ = "0.2.0"
__all__ = [
    "BrandNameGenerator",
    "SpanishBrandNameGenerator",
    "generate_spanish_names",
    "SimilarityAnalyzer",
    "ProbabilityCalculator",
    "IndecopiScraper",
]
