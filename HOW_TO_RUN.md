# 🚀 How to Run Brandy in VS Code

**Super Simple Guide - Get Started in 3 Steps!**

---

## ✅ Prerequisites

- ✅ VS Code installed
- ✅ Python 3.8+ installed
- ✅ Dependencies installed (see below)

---

## 📦 Step 1: Install Dependencies

```bash
# Open terminal in VS Code (Ctrl+`)
cd /home/user/Brandy
pip install -r requirements.txt
```

**You'll see:** Lots of packages installing... wait until it says "Successfully installed"

---

## 🎯 Step 2: Choose How to Run

### 🌟 **EASIEST METHOD: Use Pre-Configured Run Options**

1. Click **Run and Debug** icon (left sidebar) 🐛
2. Click the dropdown at the top
3. Choose any option:
   - **▶️ Simple Demo** ← Start here!
   - **🎮 Interactive Demo**
   - **📦 Batch Generator**
   - **🎨 Generate Names (CLI)**
   - **🔍 Check Name (CLI)**
   - **⚖️ Compare Names (CLI)**
4. Press **F5** or click green ▶️ button

**That's it!** The program runs in the terminal below.

---

### 💻 **METHOD 2: Run Example Files**

1. Open any example file:
   - `examples/simple_demo.py`
   - `examples/interactive_demo.py`
   - `examples/batch_generator.py`

2. Click the **▶️ Play button** (top-right corner)

   OR press **Ctrl+F5**

   OR right-click → **Run Python File in Terminal**

**Result:** Program runs immediately!

---

### 🖱️ **METHOD 3: Use Terminal Commands**

1. Open terminal: **View → Terminal** (or `` Ctrl+` ``)

2. Run any command:

```bash
# Generate brand names
python cli.py generate --count 10

# Check a name
python cli.py check "TechNova"

# Compare names
python cli.py compare "TechNova" "TekNova"

# Run examples
python examples/simple_demo.py
```

---

## 🎬 Quick Demo

**Let's generate your first brand names!**

### Using Run Configuration:
1. Press **Ctrl+Shift+D** (opens Run panel)
2. Select **"🎨 Generate Names (CLI)"**
3. Press **F5**
4. ✨ See 15 names generated!

### Using Example File:
1. Press **Ctrl+P** (Quick Open)
2. Type: `simple_demo`
3. Press **Enter**
4. Press **Ctrl+F5**
5. ✨ See demo with names, similarity analysis, and variations!

### Using Terminal:
1. Press `` Ctrl+` `` (opens terminal)
2. Type: `python cli.py generate --count 10 --style evocative`
3. Press **Enter**
4. ✨ See 10 evocative brand names!

---

## 📁 File Structure

```
Brandy/
├── 📂 examples/              ← Start here!
│   ├── simple_demo.py       ← Run this first
│   ├── interactive_demo.py
│   ├── batch_generator.py
│   └── README.md
│
├── 📂 .vscode/              ← Pre-configured for you
│   ├── launch.json          ← Run configurations
│   └── settings.json        ← Python settings
│
├── 📄 cli.py                ← Main CLI tool
├── 📄 api.py                ← REST API server
│
├── 📘 HOW_TO_RUN.md         ← You are here
├── 📘 VSCODE_GUIDE.md       ← Detailed guide
├── 📘 QUICKSTART.md         ← Command reference
└── 📘 USAGE.md              ← Full documentation
```

---

## 🎯 What Each File Does

| File | What It Does | How to Run |
|------|--------------|------------|
| `examples/simple_demo.py` | Shows 3 quick demos | Click ▶️ or press Ctrl+F5 |
| `examples/interactive_demo.py` | Menu-driven exploration | Click ▶️ or press Ctrl+F5 |
| `examples/batch_generator.py` | Generate 50+ names | Click ▶️ or press Ctrl+F5 |
| `cli.py` | Command-line tool | `python cli.py generate` |
| `api.py` | REST API server | `python api.py` |

---

## 🎨 Example Run Configurations

When you press **F5**, you can choose:

### 1. ▶️ Simple Demo
**Runs:** `examples/simple_demo.py`

**Shows:**
- 10 generated names
- Similarity analysis
- Name variations

**Output:**
```
🎨 Brandy - Brand Name Generator Demo

✨ Generated Names:
   1. Lumix
   2. NovaTek
   ...

📊 Similarity Results:
   TechNova vs TekNova = 83.7% similar
```

---

### 2. 🎨 Generate Names (CLI)
**Runs:** `python cli.py generate --count 15 --style evocative`

**Shows:**
- Beautiful table with 15 names
- Name lengths
- Generation statistics

**Output:**
```
   Generated Brand Names
╭──────┬──────────┬────────╮
│ #    │ Name     │ Length │
├──────┼──────────┼────────┤
│ 1    │ Lumira   │   6    │
│ 2    │ TechFlow │   8    │
...
```

---

### 3. 🔍 Check Name (CLI)
**Runs:** `python cli.py check "TechNova" --detailed`

**Shows:**
- Registration probability
- Risk level
- Detailed score breakdown
- Similar existing marks

---

### 4. 🌐 Start API Server
**Runs:** `python api.py`

**Shows:**
- API server starting
- URL: http://localhost:8000
- Docs: http://localhost:8000/docs

**Use:** Keep this running and access API from browser

---

## 🔧 Troubleshooting

### "No module named 'brandy'"

**Solution:**
```bash
# Make sure you're in the right directory
cd /home/user/Brandy

# Run from project root
python examples/simple_demo.py
```

### Python interpreter not found

1. Press **Ctrl+Shift+P**
2. Type: **Python: Select Interpreter**
3. Choose **Python 3.11** (or your version)

### Dependencies missing

```bash
pip install -r requirements.txt
```

### Can't find files in VS Code

1. **File → Open Folder**
2. Select `/home/user/Brandy` folder
3. NOT individual files - open the whole folder!

---

## 🎓 Learning Path

**For Beginners:**
1. ✅ Run `examples/simple_demo.py` (Click ▶️)
2. ✅ Read the output
3. ✅ Open `simple_demo.py` and read the code
4. ✅ Try `examples/interactive_demo.py`
5. ✅ Read `QUICKSTART.md`

**For Intermediate Users:**
1. ✅ Run CLI commands: `python cli.py generate --help`
2. ✅ Modify example files
3. ✅ Create your own scripts
4. ✅ Read `USAGE.md`

**For Advanced Users:**
1. ✅ Read source code in `brandy/` folder
2. ✅ Start API server: `python api.py`
3. ✅ Write custom integrations
4. ✅ Contribute improvements

---

## 💡 Quick Tips

### Tip 1: Use Keyboard Shortcuts
- `` Ctrl+` `` - Open terminal
- `Ctrl+P` - Quick file open
- `Ctrl+F5` - Run without debugging
- `F5` - Run with debugging

### Tip 2: Run Code Snippets
1. Select any Python code
2. Press **Shift+Enter**
3. Runs in interactive window!

**Try this:**
```python
from brandy import BrandNameGenerator
gen = BrandNameGenerator()
print(gen.generate(count=5))
```

### Tip 3: Split View
- `Ctrl+\` to split editor
- View code + terminal side-by-side
- Drag files to different panes

### Tip 4: Terminal History
- Press ↑ in terminal to see previous commands
- Press ↓ to go forward
- `Ctrl+R` to search history

---

## 🎯 Your First 5 Minutes

**Complete Beginner Path:**

```bash
# 1. Open VS Code
# 2. Open terminal (Ctrl+`)
# 3. Run this:

cd /home/user/Brandy
python examples/simple_demo.py

# ✅ Done! You just generated brand names!
```

**Next steps:**
```bash
# Try different styles
python cli.py generate --count 10 --style modern
python cli.py generate --count 10 --style evocative

# Check a name
python cli.py check "MyBrandName"

# Compare names
python cli.py compare "Brand1" "Brand2"
```

---

## 📚 Documentation

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **HOW_TO_RUN.md** | Quick start (you are here!) | First! |
| **QUICKSTART.md** | Command reference | When running CLI |
| **VSCODE_GUIDE.md** | Detailed VS Code tips | For VS Code users |
| **USAGE.md** | Complete guide | For in-depth learning |
| **README.md** | Project overview | Understanding architecture |

---

## ✅ Success Checklist

- [ ] Opened Brandy folder in VS Code
- [ ] Installed dependencies
- [ ] Ran `examples/simple_demo.py`
- [ ] Saw generated brand names
- [ ] Tried a CLI command
- [ ] Read the example code

**All checked?** 🎉 You're ready to generate brand names!

---

## 🆘 Still Stuck?

1. **Check you're in the right folder:**
   ```bash
   pwd
   # Should show: /home/user/Brandy
   ```

2. **Check Python works:**
   ```bash
   python3 --version
   # Should show: Python 3.11.x or similar
   ```

3. **Check dependencies installed:**
   ```bash
   pip list | grep jellyfish
   # Should show: jellyfish  1.2.1 or similar
   ```

4. **Try simplest command:**
   ```bash
   python cli.py generate
   # Should show table of names
   ```

---

## 🎉 You're Ready!

**Start generating brand names now:**

1. Click **Run and Debug** (left sidebar)
2. Select **"▶️ Simple Demo"**
3. Press **F5**

**OR**

1. Open terminal (`` Ctrl+` ``)
2. Run: `python cli.py generate --count 20`

**Happy branding!** 🎨✨

---

*For more detailed information, see:*
- *VSCODE_GUIDE.md - Complete VS Code tutorial*
- *QUICKSTART.md - All commands with examples*
- *examples/README.md - Detailed example documentation*
