#!/usr/bin/env python3
"""
Interactive Brandy Demo

Run this and enter your own brand names to check!

How to run:
- In VS Code terminal: python examples/interactive_demo.py
- Or click ▶️ Play button
"""

from brandy import BrandNameGenerator, SimilarityAnalyzer, ProbabilityCalculator, IndecopiScraper

def generate_names_interactive():
    """Generate names interactively."""
    print("\n🎨 Brand Name Generator")
    print("-" * 40)

    try:
        count = int(input("How many names to generate? (1-50): ") or "10")
        count = max(1, min(50, count))
    except:
        count = 10

    style = input("Style (evocative/modern/syllabic/hybrid): ") or "hybrid"

    generator = BrandNameGenerator()
    names = generator.generate(count=count, style=style)

    print(f"\n✨ Generated {len(names)} names:\n")
    for i, name in enumerate(names, 1):
        print(f"   {i:2d}. {name}")

    return names

def check_similarity():
    """Check similarity between two names."""
    print("\n⚖️  Name Similarity Checker")
    print("-" * 40)

    name1 = input("Enter first name: ").strip()
    name2 = input("Enter second name: ").strip()

    if not name1 or not name2:
        print("❌ Please enter both names!")
        return

    analyzer = SimilarityAnalyzer()
    result = analyzer.analyze(name1, name2)

    similarity = result['overall_score'] * 100

    print(f"\n📊 Analysis Result:")
    print(f"   {name1} vs {name2}")
    print(f"\n   Overall Similarity: {similarity:.1f}%")
    print(f"   Phonetic: {result['phonetic_score']*100:.1f}%")
    print(f"   Spelling: {result['spelling_score']*100:.1f}%")
    print(f"   Visual: {result['visual_score']*100:.1f}%")

    if result['is_conflict']:
        print("\n   ⚠️  Potential trademark conflict!")
    else:
        print("\n   ✅ Names are sufficiently different")

def generate_variations():
    """Generate variations of a name."""
    print("\n🔄 Name Variation Generator")
    print("-" * 40)

    base_name = input("Enter base name: ").strip()

    if not base_name:
        print("❌ Please enter a name!")
        return

    try:
        count = int(input("How many variations? (1-20): ") or "5")
        count = max(1, min(20, count))
    except:
        count = 5

    generator = BrandNameGenerator()
    variations = generator.generate_variations(base_name, count=count)

    print(f"\n✨ Variations of '{base_name}':\n")
    for i, var in enumerate(variations, 1):
        print(f"   {i:2d}. {var}")

def main_menu():
    """Main interactive menu."""
    print("\n" + "=" * 50)
    print("🎨 Brandy - INDECOPI Brand Name Generator")
    print("=" * 50)

    while True:
        print("\n📋 What would you like to do?\n")
        print("   1. Generate brand names")
        print("   2. Check similarity between two names")
        print("   3. Generate variations of a name")
        print("   4. Exit")

        choice = input("\nEnter choice (1-4): ").strip()

        if choice == "1":
            generate_names_interactive()
        elif choice == "2":
            check_similarity()
        elif choice == "3":
            generate_variations()
        elif choice == "4":
            print("\n👋 Goodbye! Happy branding!\n")
            break
        else:
            print("❌ Invalid choice. Please enter 1-4.")

        input("\nPress Enter to continue...")

if __name__ == "__main__":
    try:
        main_menu()
    except KeyboardInterrupt:
        print("\n\n👋 Goodbye!\n")
    except Exception as e:
        print(f"\n❌ Error: {e}\n")
