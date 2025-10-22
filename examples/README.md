# Brandy Examples

Easy-to-run examples for learning how to use Brandy.

## 🚀 Quick Start

### Method 1: Run from Terminal

```bash
# Make sure you're in the Brandy directory
cd /home/user/Brandy

# Run any example
python examples/simple_demo.py
python examples/interactive_demo.py
python examples/batch_generator.py
```

### Method 2: Run in VS Code

1. **Open the Brandy folder** in VS Code
2. **Open any example file** (e.g., `examples/simple_demo.py`)
3. **Click the ▶️ Play button** in the top-right corner
   - Or press **Ctrl+F5**
   - Or right-click → **Run Python File in Terminal**

### Method 3: Use Run Configurations

1. Click the **Run and Debug** icon (left sidebar)
2. Select a configuration from the dropdown:
   - ▶️ Simple Demo
   - 🎮 Interactive Demo
   - 📦 Batch Generator
3. Press **F5** to run

## 📝 Examples Overview

### 1. `simple_demo.py` - Quick Introduction

**What it does:**
- Generates 10 brand names
- Analyzes similarity between name pairs
- Creates variations of "Nova"

**Run it:**
```bash
python examples/simple_demo.py
```

**Perfect for:**
- First-time users
- Understanding basic features
- Quick testing

---

### 2. `interactive_demo.py` - Hands-On Exploration

**What it does:**
- Interactive menu system
- Generate names with custom parameters
- Check similarity between YOUR names
- Generate variations of YOUR chosen name

**Run it:**
```bash
python examples/interactive_demo.py
```

**Perfect for:**
- Experimenting with different options
- Testing your own brand names
- Learning by doing

**Example interaction:**
```
📋 What would you like to do?

   1. Generate brand names
   2. Check similarity between two names
   3. Generate variations of a name
   4. Exit

Enter choice (1-4): 1

How many names to generate? (1-50): 20
Style (evocative/modern/syllabic/hybrid): evocative

✨ Generated 20 names:
   1. TechFlow
   2. NovaBright
   ...
```

---

### 3. `batch_generator.py` - Mass Production

**What it does:**
- Generates 50+ names at once
- Analyzes for internal conflicts
- Saves results to files (TXT + JSON)
- Shows statistics

**Run it:**
```bash
python examples/batch_generator.py
```

**Output files:**
- `generated_names_TIMESTAMP.txt` - List of names
- `generated_names_TIMESTAMP.json` - Full data with conflicts

**Perfect for:**
- Creating large name pools
- Client presentations
- Data analysis

**Customize it:**
Edit the file to change:
```python
COUNT = 50      # Change to 100, 200, etc.
STYLE = 'hybrid'  # Change to 'evocative', 'modern', etc.
```

---

## 🎯 Which Example Should I Use?

| I want to... | Use this example |
|-------------|------------------|
| See it work quickly | `simple_demo.py` |
| Try my own names | `interactive_demo.py` |
| Generate many names | `batch_generator.py` |
| Learn the API | Read `simple_demo.py` source |
| Build something custom | Copy and modify any example |

---

## 💡 Tips for VS Code Users

### Tip 1: Split View
- Run example on left, view code on right
- **Ctrl+\\** to split editor
- Drag files to different panes

### Tip 2: Modify and Re-Run
1. Open `simple_demo.py`
2. Change `count=10` to `count=20`
3. Press **Ctrl+F5** to re-run
4. See updated results instantly

### Tip 3: Debug Mode
1. Click left of line number to set breakpoint
2. Press **F5** (not Ctrl+F5)
3. Step through code line by line
4. Inspect variables in Debug panel

### Tip 4: Run Selection
1. Select any code snippet
2. Press **Shift+Enter**
3. Code runs in Python Interactive window

**Example:**
```python
from brandy import BrandNameGenerator
gen = BrandNameGenerator()
gen.generate(count=5, style='modern')
```

Select all 3 lines → **Shift+Enter** → See results!

---

## 🔧 Troubleshooting

### "Module not found" error

**Solution 1:** Run from project root
```bash
cd /home/user/Brandy
python examples/simple_demo.py
```

**Solution 2:** Set PYTHONPATH
```bash
PYTHONPATH=/home/user/Brandy python examples/simple_demo.py
```

**Solution 3:** Install as package
```bash
cd /home/user/Brandy
pip install -e .
```

### VS Code doesn't find modules

1. Open **Command Palette** (Ctrl+Shift+P)
2. Select **Python: Select Interpreter**
3. Choose Python 3.11 or your version
4. Reload VS Code window

---

## 📚 Next Steps

After running examples:

1. **Read the code** - Examples are well-commented
2. **Modify examples** - Change parameters, try different styles
3. **Use the CLI** - Run `python cli.py generate --help`
4. **Read guides**:
   - `QUICKSTART.md` - Command reference
   - `VSCODE_GUIDE.md` - VS Code tips
   - `USAGE.md` - Complete guide

---

## 🎨 Example Output

### Simple Demo Output:
```
🎨 Brandy - Brand Name Generator Demo

1️⃣  Generating 10 brand names...
✨ Generated Names:
   1. Lumix
   2. NovaTek
   3. BrioFlow
   ...

2️⃣  Analyzing Name Similarity...
   TechNova vs TekNova
   └─ Similarity: 83.7% ⚠️  CONFLICT
```

### Batch Generator Output:
```
🎨 Generating 50 brand names...
✅ Generated 50 unique names!

📝 Sample names:
   • Lumira
   • TechFlow
   • BrioNova
   ...

💾 Names saved to: generated_names_20250122_143022.txt
💾 Details saved to: generated_names_20250122_143022.json
```

---

## 🚀 Ready to Start!

**Try this now:**

1. Open VS Code
2. Navigate to `examples/simple_demo.py`
3. Click ▶️ Play button
4. Watch it run!

**Or from terminal:**
```bash
cd /home/user/Brandy
python examples/simple_demo.py
```

**Happy coding!** 🎉
