#!/usr/bin/env python3
"""
Batch Brand Name Generator

Generates many names and saves them to a file.

How to run:
- python examples/batch_generator.py
"""

from brandy import BrandNameGenerator, SimilarityAnalyzer
import json
from datetime import datetime

def generate_batch(count=100, style='hybrid'):
    """Generate a large batch of names."""
    print(f"🎨 Generating {count} brand names...")
    print(f"   Style: {style}")
    print(f"   This may take a moment...\n")

    generator = BrandNameGenerator()
    names = generator.generate(count=count, style=style)

    print(f"✅ Generated {len(names)} unique names!\n")
    return names

def analyze_batch(names):
    """Analyze the batch for internal conflicts."""
    print("🔍 Analyzing for internal conflicts...")

    analyzer = SimilarityAnalyzer()
    conflicts = []

    # Check each name against all others
    for i, name1 in enumerate(names):
        for name2 in names[i+1:]:
            result = analyzer.analyze(name1, name2)
            if result['is_conflict']:
                conflicts.append({
                    'name1': name1,
                    'name2': name2,
                    'similarity': result['overall_score']
                })

    if conflicts:
        print(f"⚠️  Found {len(conflicts)} internal conflicts")
    else:
        print("✅ No internal conflicts found!")

    return conflicts

def save_to_file(names, conflicts, filename=None):
    """Save results to files."""
    if filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"generated_names_{timestamp}"

    # Save names to text file
    txt_file = f"{filename}.txt"
    with open(txt_file, 'w') as f:
        f.write(f"Brand Names Generated: {datetime.now()}\n")
        f.write(f"Total Names: {len(names)}\n")
        f.write("=" * 50 + "\n\n")
        for i, name in enumerate(names, 1):
            f.write(f"{i:3d}. {name}\n")

    print(f"💾 Names saved to: {txt_file}")

    # Save detailed data to JSON
    json_file = f"{filename}.json"
    data = {
        'generated_at': datetime.now().isoformat(),
        'total_count': len(names),
        'names': names,
        'conflicts': conflicts
    }

    with open(json_file, 'w') as f:
        json.dump(data, f, indent=2)

    print(f"💾 Details saved to: {json_file}")

def main():
    """Main function."""
    print("\n" + "=" * 60)
    print("🎨 Brandy - Batch Brand Name Generator")
    print("=" * 60 + "\n")

    # Configuration
    COUNT = 50  # Change this to generate more/fewer names
    STYLE = 'hybrid'  # Options: evocative, modern, syllabic, hybrid

    # Generate names
    names = generate_batch(count=COUNT, style=STYLE)

    # Show sample
    print("📝 Sample names:")
    for name in names[:10]:
        print(f"   • {name}")
    if len(names) > 10:
        print(f"   ... and {len(names) - 10} more\n")

    # Analyze for conflicts
    conflicts = analyze_batch(names)

    # Save to files
    save_to_file(names, conflicts)

    print("\n" + "=" * 60)
    print("✅ Batch generation complete!")
    print("=" * 60)
    print("\n💡 Tip: Edit COUNT variable in this file to generate more names")
    print()

if __name__ == "__main__":
    main()
