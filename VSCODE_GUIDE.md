# Running Brandy in VS Code

Complete guide to using the INDECOPI Brand Name Generator in Visual Studio Code.

## 📋 Table of Contents
1. [Opening the Project](#1-opening-the-project)
2. [Setting Up Python Environment](#2-setting-up-python-environment)
3. [Installing Dependencies](#3-installing-dependencies)
4. [Running from Terminal](#4-running-from-terminal)
5. [Running Python Files Directly](#5-running-python-files-directly)
6. [Creating Run Configurations](#6-creating-run-configurations)
7. [Using Interactive Python](#7-using-interactive-python)
8. [Recommended Extensions](#8-recommended-extensions)

---

## 1. Opening the Project

### Option A: Open Folder
1. Open VS Code
2. Click **File → Open Folder**
3. Navigate to `/home/user/Brandy`
4. Click **Select Folder**

### Option B: From Command Line
```bash
cd /home/user/Brandy
code .
```

---

## 2. Setting Up Python Environment

### Check Python Version
1. Open VS Code Terminal: **View → Terminal** (or `Ctrl+``)
2. Check Python:
```bash
python3 --version
```
Should show: `Python 3.11.14` or similar

### Select Python Interpreter
1. Press **Ctrl+Shift+P** (Command Palette)
2. Type: **Python: Select Interpreter**
3. Choose: **Python 3.11.14** or your installed version

### (Optional) Create Virtual Environment
If you want isolated dependencies:

```bash
# In VS Code terminal
python3 -m venv venv

# Activate it
source venv/bin/activate  # Linux/Mac
# OR
venv\Scripts\activate     # Windows

# VS Code should detect it automatically
```

---

## 3. Installing Dependencies

### In VS Code Terminal
```bash
pip install -r requirements.txt
```

You'll see installation progress in the terminal.

### Verify Installation
```bash
pip list | grep jellyfish
pip list | grep click
```

---

## 4. Running from Terminal

### Open Integrated Terminal
- **View → Terminal** (or `Ctrl+``)
- Or click terminal icon at bottom

### Run CLI Commands

```bash
# Generate names
python cli.py generate --count 10

# Check a name
python cli.py check "TechNova" --detailed

# Compare names
python cli.py compare "TechNova" "TekNova"

# Generate variations
python cli.py variations "Nova" --count 5

# Start API server
python api.py
```

---

## 5. Running Python Files Directly

### Method 1: Right-Click Run
1. Open any Python file (e.g., `cli.py`)
2. Right-click in the editor
3. Select **Run Python File in Terminal**

### Method 2: Play Button
1. Open a Python file
2. Click the **▶️ Play** button in top-right corner
3. File runs in terminal

### Method 3: Keyboard Shortcut
1. Open Python file
2. Press **Ctrl+F5** (Run Without Debugging)
3. Or **F5** (Run with Debugging)

---

## 6. Creating Run Configurations

Create custom run configurations for easy access.

### Create `.vscode/launch.json`

1. Click **Run → Add Configuration**
2. Or create file manually:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Generate Brand Names",
            "type": "debugpy",
            "request": "launch",
            "program": "${workspaceFolder}/cli.py",
            "console": "integratedTerminal",
            "args": ["generate", "--count", "10", "--style", "evocative"]
        },
        {
            "name": "Check Brand Name",
            "type": "debugpy",
            "request": "launch",
            "program": "${workspaceFolder}/cli.py",
            "console": "integratedTerminal",
            "args": ["check", "TechNova", "--detailed"]
        },
        {
            "name": "Start API Server",
            "type": "debugpy",
            "request": "launch",
            "program": "${workspaceFolder}/api.py",
            "console": "integratedTerminal"
        },
        {
            "name": "Run Tests",
            "type": "debugpy",
            "request": "launch",
            "module": "pytest",
            "args": ["tests/", "-v"],
            "console": "integratedTerminal"
        }
    ]
}
```

3. Press **F5** to run selected configuration
4. Choose from dropdown in **Run and Debug** panel

---

## 7. Using Interactive Python

### Method 1: Python Interactive Window

1. Open any Python file
2. Select code you want to run
3. Press **Shift+Enter**
4. Code runs in interactive window

**Example:**
```python
from brandy import BrandNameGenerator

generator = BrandNameGenerator()
names = generator.generate(count=5)
print(names)
```

Select these lines → **Shift+Enter**

### Method 2: Jupyter Notebook Style

Create `demo.ipynb` file:

1. **File → New File → Jupyter Notebook**
2. Add code cells:

```python
# Cell 1: Import
from brandy import BrandNameGenerator, SimilarityAnalyzer

# Cell 2: Generate
generator = BrandNameGenerator()
names = generator.generate(count=10, style='evocative')
names

# Cell 3: Analyze
analyzer = SimilarityAnalyzer()
result = analyzer.analyze("TechNova", "TekNova")
print(f"Similarity: {result['overall_score']*100:.1f}%")
```

3. Run each cell with **Shift+Enter**

### Method 3: Python REPL

1. Open terminal in VS Code
2. Type: `python3`
3. Interactive Python shell opens:

```python
>>> from brandy import BrandNameGenerator
>>> gen = BrandNameGenerator()
>>> gen.generate(count=5)
['Lumix', 'Novtek', 'Brius', 'Flowa', 'Terix']
```

---

## 8. Recommended Extensions

### Essential Extensions

Install these from **Extensions** panel (`Ctrl+Shift+X`):

1. **Python** (Microsoft)
   - Python language support
   - IntelliSense, debugging, testing

2. **Pylance** (Microsoft)
   - Fast, feature-rich language server
   - Type checking, auto-imports

3. **Python Debugger** (Microsoft)
   - Advanced debugging features

### Helpful Extensions

4. **Jupyter** (Microsoft)
   - Run Jupyter notebooks in VS Code

5. **autoDocstring** (Nils Werner)
   - Auto-generate docstrings

6. **Python Test Explorer**
   - Visual test runner

7. **GitLens**
   - Enhanced Git capabilities

### Install Extensions
```bash
# From command line
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.debugpy
```

---

## 9. Quick Start Examples

### Example 1: Generate Names

1. Open terminal in VS Code
2. Run:
```bash
python cli.py generate --count 20 --style modern
```

### Example 2: Run Python Script

Create `test_brandy.py`:
```python
from brandy import BrandNameGenerator

def main():
    gen = BrandNameGenerator()
    names = gen.generate(count=10, style='evocative')

    print("🎨 Generated Brand Names:")
    for i, name in enumerate(names, 1):
        print(f"  {i}. {name}")

if __name__ == "__main__":
    main()
```

**Run it:**
- Click ▶️ button
- Or press `Ctrl+F5`
- Or right-click → **Run Python File in Terminal**

### Example 3: Debug Mode

1. Set breakpoint (click left of line number)
2. Press **F5**
3. Choose **Python File**
4. Debugger stops at breakpoint
5. Inspect variables, step through code

---

## 10. Common Tasks

### Task: Generate 50 Names and Save to File

Create `generate_batch.py`:
```python
from brandy import BrandNameGenerator

generator = BrandNameGenerator()
names = generator.generate(count=50, style='hybrid')

# Save to file
with open('generated_names.txt', 'w') as f:
    for name in names:
        f.write(f"{name}\n")

print(f"✅ Generated {len(names)} names → generated_names.txt")
```

Run: **Ctrl+F5**

### Task: Analyze Multiple Names

Create `analyze_names.py`:
```python
from brandy import SimilarityAnalyzer

analyzer = SimilarityAnalyzer()

names_to_check = [
    ("TechNova", "TekNova"),
    ("Apple", "Appel"),
    ("Google", "Googol")
]

print("📊 Similarity Analysis:\n")
for name1, name2 in names_to_check:
    result = analyzer.analyze(name1, name2)
    similarity = result['overall_score'] * 100
    print(f"{name1:15} vs {name2:15} = {similarity:5.1f}% similar")
```

Run: **Ctrl+F5**

### Task: Interactive Testing

Open terminal, start Python:
```python
python3

>>> from brandy import BrandNameGenerator
>>> gen = BrandNameGenerator()

# Try different styles
>>> gen.generate(count=5, style='evocative')
>>> gen.generate(count=5, style='modern')
>>> gen.generate(count=5, style='syllabic')

# Generate variations
>>> gen.generate_variations("Nova", count=10)
```

---

## 11. Troubleshooting

### Issue: "Module not found"

**Solution:**
1. Check Python interpreter: **Ctrl+Shift+P** → **Python: Select Interpreter**
2. Reinstall dependencies:
```bash
pip install -r requirements.txt
```

### Issue: Terminal not opening

**Solution:**
- **View → Terminal**
- Or `Ctrl+``
- Or **Terminal → New Terminal**

### Issue: Files not found

**Solution:**
- Make sure you opened the **folder** `/home/user/Brandy`
- Not individual files
- Check Explorer panel on left

### Issue: Chrome errors when checking names

**Solution:**
- Install Google Chrome browser
- Or use generator without INDECOPI checking:
```bash
python cli.py generate --count 10 --no-check
```

---

## 12. VS Code Shortcuts Cheat Sheet

| Action | Shortcut |
|--------|----------|
| Open Terminal | `` Ctrl+` `` |
| Command Palette | `Ctrl+Shift+P` |
| Run Python File | `Ctrl+F5` |
| Run Selection | `Shift+Enter` |
| Toggle Explorer | `Ctrl+Shift+E` |
| Search Files | `Ctrl+P` |
| Find in Files | `Ctrl+Shift+F` |
| New Terminal | `` Ctrl+Shift+` `` |
| Split Terminal | `Ctrl+Shift+5` |

---

## 13. Project Structure in VS Code

```
Brandy/
├── 📁 brandy/              # Core package
│   ├── __init__.py
│   ├── name_generator.py
│   ├── similarity_analyzer.py
│   └── ...
├── 📁 tests/               # Tests
├── 📄 cli.py              # ← Run this for CLI
├── 📄 api.py              # ← Run this for API
├── 📄 requirements.txt
├── 📄 QUICKSTART.md       # Quick reference
├── 📄 USAGE.md           # Full guide
└── 📄 README.md          # Overview
```

**Click any file** in Explorer to open it.

---

## 🎯 Quick Start Checklist

- [ ] Open folder in VS Code
- [ ] Select Python interpreter
- [ ] Open terminal (`` Ctrl+` ``)
- [ ] Install dependencies: `pip install -r requirements.txt`
- [ ] Run: `python cli.py generate --count 10`
- [ ] ✅ Success!

---

## 💡 Pro Tips

1. **Multi-cursor editing**: `Alt+Click` to place multiple cursors
2. **Quick file switch**: `Ctrl+P` → type filename
3. **Integrated Git**: Built-in Git panel (`Ctrl+Shift+G`)
4. **Split editor**: `Ctrl+\` to split view
5. **Zen mode**: `Ctrl+K Z` for distraction-free coding

---

## 🚀 Ready to Code!

**Try this now:**

1. Open VS Code
2. Open folder: `/home/user/Brandy`
3. Open terminal: `` Ctrl+` ``
4. Run:
```bash
python cli.py generate --count 10 --style evocative
```

**Success!** 🎉

For more examples, see:
- `QUICKSTART.md` - Command reference
- `USAGE.md` - Detailed usage guide
- `README.md` - Project overview
