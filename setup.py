"""
Setup script for Brandy - INDECOPI Brand Name Generator
"""

from setuptools import setup, find_packages
from pathlib import Path

# Read the contents of README file
this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text()

setup(
    name="brandy-indecopi",
    version="0.1.0",
    author="Brandy Team",
    author_email="info@brandy.example",
    description="INDECOPI-compliant brand name generator for Peru",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/brandy",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Intended Audience :: Legal Industry",
        "Topic :: Office/Business",
        "Topic :: Text Processing :: Linguistic",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=[
        "jellyfish>=1.0.0",
        "python-Levenshtein>=0.21.0",
        "beautifulsoup4>=4.12.0",
        "selenium>=4.15.0",
        "webdriver-manager>=4.0.0",
        "requests>=2.31.0",
        "lxml>=4.9.0",
        "pronouncing>=0.2.0",
        "Faker>=20.0.0",
        "click>=8.1.0",
        "rich>=13.7.0",
        "pandas>=2.0.0",
        "numpy>=1.24.0",
        "python-dotenv>=1.0.0",
        "tqdm>=4.66.0",
    ],
    extras_require={
        "api": [
            "fastapi>=0.104.0",
            "uvicorn>=0.24.0",
            "pydantic>=2.0.0",
        ],
        "dev": [
            "pytest>=7.4.0",
            "pytest-cov>=4.1.0",
            "black>=23.0.0",
            "flake8>=6.1.0",
            "mypy>=1.7.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "brandy=cli:cli",
        ],
    },
)
