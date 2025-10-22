#!/usr/bin/env python3
"""
Simple Brandy Demo - Run this in VS Code!

How to run:
1. Open this file in VS Code
2. Click the ▶️ Play button in top-right
   OR
3. Press Ctrl+F5
   OR
4. Right-click → "Run Python File in Terminal"
"""

from brandy import BrandNameGenerator, SimilarityAnalyzer

def main():
    print("🎨 Brandy - Brand Name Generator Demo\n")

    # 1. Generate some brand names
    print("=" * 50)
    print("1️⃣  Generating 10 brand names...")
    print("=" * 50)

    generator = BrandNameGenerator()
    names = generator.generate(count=10, style='evocative')

    print("\n✨ Generated Names:")
    for i, name in enumerate(names, 1):
        print(f"   {i:2d}. {name}")

    # 2. Analyze similarity
    print("\n" + "=" * 50)
    print("2️⃣  Analyzing Name Similarity...")
    print("=" * 50)

    analyzer = SimilarityAnalyzer()

    test_pairs = [
        ("TechNova", "TekNova"),
        ("Apple", "Appel"),
        ("Google", "Googol")
    ]

    print("\n📊 Similarity Results:")
    for name1, name2 in test_pairs:
        result = analyzer.analyze(name1, name2)
        similarity = result['overall_score'] * 100
        conflict = "⚠️  CONFLICT" if result['is_conflict'] else "✅ OK"

        print(f"\n   {name1} vs {name2}")
        print(f"   └─ Similarity: {similarity:.1f}% {conflict}")
        print(f"      • Phonetic: {result['phonetic_score']*100:.1f}%")
        print(f"      • Spelling: {result['spelling_score']*100:.1f}%")

    # 3. Generate variations
    print("\n" + "=" * 50)
    print("3️⃣  Generating Variations of 'Nova'...")
    print("=" * 50)

    variations = generator.generate_variations("Nova", count=8)

    print("\n🔄 Variations:")
    for i, var in enumerate(variations, 1):
        print(f"   {i}. {var}")

    print("\n" + "=" * 50)
    print("✅ Demo Complete!")
    print("=" * 50)
    print("\nNext steps:")
    print("  • Try modifying the code above")
    print("  • Run: python cli.py generate --count 20")
    print("  • Read: QUICKSTART.md for more examples")
    print()

if __name__ == "__main__":
    main()
