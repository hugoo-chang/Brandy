# Brandy - INDECOPI Brand Name Generator

An intelligent brand name generator that complies with INDECOPI (Peruvian trademark entity) guidelines. This tool generates distinctive brand names and analyzes their probability of successful trademark registration based on phonetic and spelling similarity with existing registered marks.

## Features

- **Smart Name Generation**: Creates distinctive, evocative brand names following INDECOPI guidelines
- **🇵🇪 Spanish/Peruvian Generator NEW!**: Culturally-aware name generation for Spanish speakers in Peru
- **INDECOPI Registry Integration**: Scrapes and analyzes the INDECOPI trademark database
- **Phonetic Analysis**: Uses multiple phonetic algorithms (Soundex, Metaphone, NYSIIS)
- **Spelling Similarity**: Levenshtein distance-based comparison
- **Registration Probability**: Calculates likelihood of successful trademark registration (0-100%)
- **CLI Interface**: Easy-to-use command-line tool

### 🆕 Spanish/Peruvian Name Generator (v0.2.0)

Generate brand names that resonate with Spanish-speaking audiences in Peru!

**Why use it?**
- ✅ Natural Spanish pronunciation
- ✅ Peruvian cultural references (Inti, Pacha, Andes...)
- ✅ Spanish phonetic patterns
- ✅ Avoids awkward sounds for Spanish speakers
- ✅ Uses diminutives popular in Peru (-ito, -ita)

```python
from brandy import SpanishBrandNameGenerator

gen = SpanishBrandNameGenerator()
names = gen.generate(count=10, style='peruvian_cultural')
# ['Intiito', 'Pachaandes', 'Solito', 'Killaalma', ...]
```

**[📖 Read full documentation →](SPANISH_GENERATOR.md)**

## INDECOPI Compliance

The generator follows Peruvian trademark law (Andean Decision 486) by:

- Avoiding generic names
- Avoiding descriptive terms
- Ensuring distinctiveness
- Checking for confusingly similar existing marks
- Prioritizing evocative (suggestive) names

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd Brandy

# Install dependencies
pip install -r requirements.txt
```

## Usage

### Command Line Interface

```bash
# Generate brand names
python cli.py generate --count 10 --category "technology"

# Check a specific name
python cli.py check "MiMarca"

# Advanced options
python cli.py generate --count 20 --min-length 5 --max-length 10 --category "food"
```

### Python API

```python
from brandy import BrandNameGenerator

# Initialize generator
generator = BrandNameGenerator()

# Generate names
names = generator.generate(count=10, category="technology")

# Check specific name
result = generator.check_name("MiMarca")
print(f"Registration Probability: {result.probability}%")
```

## Architecture

```
├── brandy/
│   ├── __init__.py
│   ├── name_generator.py          # Name generation engine
│   ├── indecopi_scraper.py        # INDECOPI registry interface
│   ├── similarity_analyzer.py     # Phonetic/spelling analysis
│   ├── probability_calculator.py  # Registration probability
│   └── config.py                  # Configuration
├── cli.py                         # CLI interface
├── api.py                         # Optional REST API
├── tests/                         # Unit tests
└── data/                          # Cached trademark data
```

## How It Works

1. **Name Generation**: Combines phonemes and syllables to create distinctive names
2. **Registry Check**: Searches INDECOPI database for similar existing marks
3. **Similarity Analysis**: Compares phonetically and by spelling
4. **Probability Calculation**: Scores based on:
   - Distinctiveness (40%)
   - Phonetic conflicts (30%)
   - Spelling similarity (20%)
   - Category overlap (10%)

## Legal Disclaimer

This tool provides estimates only. Actual trademark registration decisions are made by INDECOPI. Always consult with a qualified intellectual property attorney before filing a trademark application.

## License

MIT License
