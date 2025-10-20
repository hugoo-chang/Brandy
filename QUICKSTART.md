# Brandy - Quick Start Guide

## ✅ Installation Complete!

All dependencies are installed and ready to use.

## 🚀 Command Reference

### 1. Generate Brand Names

```bash
# Generate 10 names (default)
python cli.py generate

# Generate 20 names in evocative style
python cli.py generate --count 20 --style evocative

# Generate short modern names (4-6 characters)
python cli.py generate --count 15 --style modern --min-length 4 --max-length 6

# Generate for specific category
python cli.py generate --count 10 --category technology
```

**Styles:**
- `evocative` - Meaningful, suggestive names (TechNova, BioFlow)
- `syllabic` - Phonetically balanced names
- `modern` - Short, tech-style names (like Flickr, Tumblr)
- `hybrid` - Mix of all styles (default)

### 2. Check a Name

```bash
# Simple check
python cli.py check "MiMarca"

# Detailed check with category (NICE classification)
python cli.py check "TechFlow" --category 9 --detailed

# Check for services category
python cli.py check "CloudPro" --category 42 --detailed
```

**Common NICE Classes:**
- `9` - Technology, software, electronics
- `25` - Clothing
- `29-33` - Food and beverages
- `35` - Advertising, business
- `42` - IT services
- `43` - Restaurant services

### 3. Compare Names

```bash
python cli.py compare "TechNova" "TekNova"
```

Shows similarity percentage and potential conflicts.

### 4. Generate Variations

```bash
python cli.py variations "Nova" --count 10
```

Creates alternative versions of a base name.

### 5. Clear Cache

```bash
python cli.py clear-cache
```

Clears stored INDECOPI search results.

## 🐍 Python API Usage

```python
from brandy import BrandNameGenerator, SimilarityAnalyzer, ProbabilityCalculator

# Generate names
generator = BrandNameGenerator()
names = generator.generate(count=10, style='evocative')

# Analyze similarity
analyzer = SimilarityAnalyzer()
result = analyzer.analyze("Name1", "Name2")
print(f"Similarity: {result['overall_score']*100:.1f}%")

# Check registration probability (requires INDECOPI data)
from brandy import IndecopiScraper
scraper = IndecopiScraper()
calculator = ProbabilityCalculator()

existing_marks = scraper.search("MiMarca", search_type='phonetic')
result = calculator.calculate("MiMarca", existing_marks)
print(f"Probability: {result['probability']}%")
```

## 🌐 REST API

Start the server:
```bash
python api.py
```

Access at: http://localhost:8000

API Documentation: http://localhost:8000/docs

### Example API Calls

```bash
# Generate names
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{"count": 10, "style": "evocative"}'

# Check a name
curl -X POST "http://localhost:8000/check" \
  -H "Content-Type: application/json" \
  -d '{"name": "TechNova", "category": 9}'

# Compare names
curl -X POST "http://localhost:8000/compare" \
  -H "Content-Type: application/json" \
  -d '{"name1": "TechNova", "name2": "TekNova"}'
```

## 📊 Understanding Results

### Registration Probability
- **80-100%** ✅ LOW RISK - Excellent chance
- **60-80%** ⚠️ MEDIUM RISK - Some concerns
- **40-60%** ❌ HIGH RISK - Several conflicts
- **0-40%** 🚫 VERY HIGH RISK - Likely rejection

### Similarity Scores
- **>85%** - Very similar, likely conflict
- **70-85%** - Similar, potential conflict
- **50-70%** - Somewhat similar
- **<50%** - Different enough

## ⚠️ Important Notes

### INDECOPI Scraper
The INDECOPI scraper requires **Google Chrome** to be installed:

```bash
# Install Chrome on Ubuntu/Debian
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

# Or on other systems, download from:
# https://www.google.com/chrome/
```

Without Chrome, the scraper can't fetch real trademark data, but the name generator and similarity analysis still work perfectly.

### Legal Disclaimer
This tool provides **estimates only**. Actual trademark registration decisions are made by INDECOPI. Always consult with a qualified intellectual property attorney before filing.

## 🔧 Troubleshooting

### Chrome/Selenium Issues
If you see Chrome binary errors:
1. Install Google Chrome
2. Or disable INDECOPI checking and use generator only

### Import Errors
```bash
# Reinstall dependencies
pip install -r requirements.txt
```

### Cache Issues
```bash
python cli.py clear-cache
```

## 📚 Full Documentation

- **USAGE.md** - Comprehensive usage guide
- **README.md** - Project overview
- API docs at `/docs` when server is running

## 🎯 Quick Examples

```bash
# Generate 50 names and find the best ones
python cli.py generate --count 50 --style hybrid

# Check your favorite name in detail
python cli.py check "YourBrandName" --detailed

# Compare with competitor
python cli.py compare "YourBrand" "CompetitorBrand"

# Create variations of a good name
python cli.py variations "GoodName" --count 20
```

## 💡 Best Practices

1. **Generate many options** - Create 30-50 names to choose from
2. **Check before committing** - Always run detailed check
3. **Use appropriate category** - Specify NICE class for accuracy
4. **Try variations** - If you like a name, generate variations
5. **Consult an attorney** - Always get professional legal advice

---

**Need Help?**
- Read USAGE.md for detailed examples
- Visit http://localhost:8000/docs for API documentation
- Check README.md for system architecture

**Happy Branding! 🎨**
