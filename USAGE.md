# Brandy Usage Guide

Complete guide to using the INDECOPI Brand Name Generator.

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [CLI Usage](#cli-usage)
4. [Python API](#python-api)
5. [REST API](#rest-api)
6. [Understanding Results](#understanding-results)
7. [Best Practices](#best-practices)

## Installation

### Basic Installation

```bash
# Clone the repository
git clone <repository-url>
cd Brandy

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Installation with API Support

```bash
pip install -r requirements.txt
pip install fastapi uvicorn pydantic
```

### Development Installation

```bash
pip install -e ".[dev]"
```

## Quick Start

### Generate Your First Brand Names

```bash
# Generate 10 names
python cli.py generate

# Generate 20 technology-focused names
python cli.py generate --count 20 --category technology

# Generate short, modern names
python cli.py generate --style modern --min-length 4 --max-length 6
```

### Check a Specific Name

```bash
# Basic check
python cli.py check "MiMarca"

# Detailed check with category
python cli.py check "TechNova" --category 9 --detailed
```

## CLI Usage

### Generate Command

Generate brand names with various options:

```bash
python cli.py generate [OPTIONS]
```

**Options:**

- `--count, -c INTEGER`: Number of names to generate (default: 10)
- `--min-length INTEGER`: Minimum name length (default: 5)
- `--max-length INTEGER`: Maximum name length (default: 10)
- `--category TEXT`: Business category (default: general)
- `--style CHOICE`: Generation style
  - `evocative`: Meaningful, suggestive names
  - `syllabic`: Phonetically balanced names
  - `modern`: Tech-style names (short, punchy)
  - `hybrid`: Mix of all styles (default)
- `--check/--no-check`: Check against INDECOPI registry

**Examples:**

```bash
# Generate 5 evocative names for food business
python cli.py generate --count 5 --category food --style evocative

# Generate and immediately check names
python cli.py generate --count 10 --check

# Generate very short modern names
python cli.py generate --style modern --min-length 3 --max-length 5
```

### Check Command

Check a specific brand name:

```bash
python cli.py check NAME [OPTIONS]
```

**Options:**

- `--category INTEGER`: NICE classification (1-45)
- `--detailed/--simple`: Show detailed analysis (default: simple)

**Examples:**

```bash
# Simple check
python cli.py check "MiMarca"

# Detailed check for technology category (Class 9)
python cli.py check "TechFlow" --category 9 --detailed

# Check for services (Class 42)
python cli.py check "CloudPro" --category 42 --detailed
```

### Compare Command

Compare two names for similarity:

```bash
python cli.py compare NAME1 NAME2
```

**Example:**

```bash
python cli.py compare "TechNova" "TekNova"
```

### Variations Command

Generate variations of an existing name:

```bash
python cli.py variations NAME [OPTIONS]
```

**Options:**

- `--count, -c INTEGER`: Number of variations (default: 5)

**Example:**

```bash
python cli.py variations "Nova" --count 10
```

### Clear Cache

Clear the INDECOPI search cache:

```bash
python cli.py clear-cache
```

## Python API

### Basic Usage

```python
from brandy import BrandNameGenerator, ProbabilityCalculator, IndecopiScraper

# Initialize components
generator = BrandNameGenerator()
scraper = IndecopiScraper()
calculator = ProbabilityCalculator()

# Generate names
names = generator.generate(count=10, style='evocative')
print(names)

# Check a name
existing_marks = scraper.search("MiMarca", search_type='phonetic')
result = calculator.calculate("MiMarca", existing_marks)

print(f"Probability: {result['probability']}%")
print(f"Risk Level: {result['risk_level']}")
```

### Advanced Usage

```python
from brandy import BrandNameGenerator, SimilarityAnalyzer

# Custom generation
generator = BrandNameGenerator()

# Generate with specific parameters
names = generator.generate(
    count=20,
    min_length=6,
    max_length=8,
    category='technology',
    style='modern'
)

# Generate variations
base_name = "Nova"
variations = generator.generate_variations(base_name, count=10)

# Similarity analysis
analyzer = SimilarityAnalyzer()

# Compare two names
result = analyzer.analyze("TechNova", "TekNova")
print(f"Phonetic similarity: {result['phonetic_score']}")
print(f"Spelling similarity: {result['spelling_score']}")
print(f"Conflict? {result['is_conflict']}")

# Batch analysis
target = "MyBrand"
existing = ["MyBrands", "MiBrand", "YourBrand"]
conflicts = analyzer.batch_analyze(target, existing)

for conflict in conflicts:
    print(f"{conflict['existing_name']}: {conflict['overall_score']}")
```

### Batch Processing

```python
from brandy import BrandNameGenerator, ProbabilityCalculator, IndecopiScraper

generator = BrandNameGenerator()
scraper = IndecopiScraper()
calculator = ProbabilityCalculator()

# Generate many names
candidates = generator.generate(count=50, style='hybrid')

# Batch check (use cached results)
existing_database = scraper.search("*", search_type='phonetic')  # Broad search

# Calculate probabilities for all candidates
results = calculator.batch_calculate(
    candidates,
    existing_database,
    category=9  # Technology
)

# Show top 10 best candidates
for result in results[:10]:
    print(f"{result['name']}: {result['probability']}% ({result['risk_level']})")
```

## REST API

### Starting the API Server

```bash
python api.py
```

The API will be available at `http://localhost:8000`

API Documentation: `http://localhost:8000/docs`

### API Endpoints

#### Generate Names

**POST** `/generate`

```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "count": 10,
    "min_length": 5,
    "max_length": 10,
    "category": "technology",
    "style": "evocative"
  }'
```

#### Check Name

**POST** `/check`

```bash
curl -X POST "http://localhost:8000/check" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "TechNova",
    "category": 9
  }'
```

#### Compare Names

**POST** `/compare`

```bash
curl -X POST "http://localhost:8000/compare" \
  -H "Content-Type: application/json" \
  -d '{
    "name1": "TechNova",
    "name2": "TekNova"
  }'
```

#### Generate Variations

**GET** `/variations/{name}?count=5`

```bash
curl "http://localhost:8000/variations/Nova?count=10"
```

## Understanding Results

### Probability Score (0-100%)

- **80-100%**: LOW RISK - Excellent chance of registration
- **60-80%**: MEDIUM RISK - Good potential, minor concerns
- **40-60%**: HIGH RISK - Several conflicts, consult attorney
- **0-40%**: VERY HIGH RISK - Many conflicts, likely rejection

### Score Components

1. **Distinctiveness (40% weight)**
   - Measures how unique and non-generic the name is
   - Penalizes descriptive, generic, or common patterns

2. **Phonetic Conflicts (30% weight)**
   - How similar the name sounds to existing marks
   - Uses Metaphone, Soundex, NYSIIS algorithms

3. **Spelling Similarity (20% weight)**
   - Visual and textual similarity to existing marks
   - Uses Levenshtein distance and Jaro-Winkler

4. **Category Overlap (10% weight)**
   - Conflicts within same NICE classification
   - Same category conflicts are heavily penalized

### NICE Classification

Some common classes for Peru:

- **Class 9**: Technology, software, electronics
- **Class 25**: Clothing, footwear
- **Class 29-33**: Food and beverages
- **Class 35**: Advertising, business services
- **Class 42**: Technology services, software development
- **Class 43**: Food services, restaurants

[Full NICE Classification](https://www.wipo.int/classifications/nice/en/)

## Best Practices

### 1. Generate Multiple Options

Always generate more names than you need:

```bash
python cli.py generate --count 50 --style hybrid
```

### 2. Check Before You Love It

Don't get attached to a name before checking:

```bash
python cli.py check "YourFavoriteName" --detailed
```

### 3. Use Appropriate Category

Always specify your NICE classification:

```bash
python cli.py check "TechNova" --category 9
```

### 4. Consider Variations

If a name has conflicts, try variations:

```bash
python cli.py variations "Nova" --count 20
```

### 5. Combine Styles

Use hybrid style for diverse options:

```bash
python cli.py generate --style hybrid --count 30
```

### 6. Consult a Professional

**Always consult an IP attorney before filing**, especially if:
- Probability is below 80%
- Operating in competitive industries
- Significant investment in branding planned

### 7. Understand Limitations

This tool provides estimates only. Actual decisions are made by INDECOPI based on:
- Complete examination
- Opposition period
- Legal precedents
- Examiner discretion

## Troubleshooting

### Selenium Issues

If you encounter Selenium errors:

```bash
# Update Chrome driver
pip install --upgrade webdriver-manager

# Try non-headless mode (edit .env)
HEADLESS_BROWSER=false
```

### Cache Issues

Clear cache if results seem outdated:

```bash
python cli.py clear-cache
```

### Import Errors

Ensure all dependencies are installed:

```bash
pip install -r requirements.txt
```

### Network Errors

The scraper requires internet access. Check your connection and INDECOPI website availability.

## Legal Disclaimer

This tool provides estimates based on automated analysis. It does not guarantee trademark registration success. Always consult with a qualified intellectual property attorney before filing a trademark application with INDECOPI.

Trademark registration decisions are made by INDECOPI examiners based on comprehensive legal analysis, opposition proceedings, and regulatory requirements.
