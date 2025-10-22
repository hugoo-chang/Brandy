#!/usr/bin/env python3
"""
Spanish/Peruvian Name Generator Demo

Shows the improvement of culturally-aware name generation for Peru.

How to run:
- python examples/spanish_demo.py
- Or click ▶️ Play button in VS Code
"""

from brandy import BrandNameGenerator, SpanishBrandNameGenerator, generate_spanish_names

def main():
    print("\n" + "=" * 70)
    print("🇵🇪  Spanish/Peruvian-Enhanced Brand Name Generator Demo")
    print("=" * 70)

    print("\n📊 COMPARISON: Generic vs. Spanish/Peruvian-Aware Generator\n")

    # Generate with generic generator
    print("─" * 70)
    print("❌ BEFORE: Generic Generator (English-biased)")
    print("─" * 70)
    generic_gen = BrandNameGenerator()
    generic_names = generic_gen.generate(count=10, style='evocative')

    for i, name in enumerate(generic_names, 1):
        print(f"   {i:2d}. {name}")

    print("\n   Issues:")
    print("   • Many awkward consonant clusters for Spanish speakers")
    print("   • No cultural resonance with Peru")
    print("   • Some difficult to pronounce in Spanish\n")

    # Generate with Spanish generator
    print("─" * 70)
    print("✅ AFTER: Spanish/Peruvian-Aware Generator")
    print("─" * 70)
    spanish_gen = SpanishBrandNameGenerator()
    spanish_names = spanish_gen.generate(count=10, style='hybrid', cultural_weight=0.3)

    for i, name in enumerate(spanish_names, 1):
        print(f"   {i:2d}. {name}")

    print("\n   Benefits:")
    print("   • Natural Spanish pronunciation")
    print("   • Culturally resonant with Peru")
    print("   • Uses common Spanish syllables")
    print("   • Follows Spanish phonetic patterns\n")

    # Show different Spanish styles
    print("=" * 70)
    print("🎨 DIFFERENT SPANISH STYLES")
    print("=" * 70)

    styles = {
        'spanish_evocative': '🌟 Spanish Evocative (Meaningful, culturally resonant)',
        'spanish_syllabic': '📝 Spanish Syllabic (Natural Spanish sounds)',
        'peruvian_cultural': '🇵🇪 Peruvian Cultural (Andean heritage emphasis)',
        'modern_spanish': '💻 Modern Spanish (Tech-friendly but Spanish)',
    }

    for style, description in styles.items():
        print(f"\n{description}")
        print("─" * 70)
        names = spanish_gen.generate(count=8, style=style)
        print("   " + "  •  ".join(names))

    # Show category-specific generation
    print("\n\n" + "=" * 70)
    print("🏢 CATEGORY-SPECIFIC NAMES (Using Spanish Word Roots)")
    print("=" * 70)

    categories = {
        'technology': '💻 Technology',
        'food': '🍽️  Food & Beverage',
        'nature': '🌿 Nature/Eco',
        'energy': '⚡ Energy',
        'creativity': '🎨 Creative/Arts',
    }

    for category, label in categories.items():
        print(f"\n{label}")
        print("─" * 70)
        names = spanish_gen.generate(count=6, style='spanish_evocative', category=category)
        print("   " + "  •  ".join(names))

    # Show cultural weight effect
    print("\n\n" + "=" * 70)
    print("🎚️  CULTURAL WEIGHT EFFECT")
    print("=" * 70)

    print("\n📉 Low Cultural Weight (0.1) - More generic Spanish")
    print("─" * 70)
    low_cultural = spanish_gen.generate(count=8, style='hybrid', cultural_weight=0.1)
    print("   " + "  •  ".join(low_cultural))

    print("\n📊 Medium Cultural Weight (0.5) - Balanced")
    print("─" * 70)
    med_cultural = spanish_gen.generate(count=8, style='hybrid', cultural_weight=0.5)
    print("   " + "  •  ".join(med_cultural))

    print("\n📈 High Cultural Weight (0.9) - Very Peruvian")
    print("─" * 70)
    high_cultural = spanish_gen.generate(count=8, style='hybrid', cultural_weight=0.9)
    print("   " + "  •  ".join(high_cultural))

    # Show variations
    print("\n\n" + "=" * 70)
    print("🔄 SPANISH VARIATIONS (with diminutives, common in Peru!)")
    print("=" * 70)

    base_names = ["Sol", "Mar", "Inti", "Luna"]
    for base in base_names:
        variations = spanish_gen.generate_variations(base, count=5)
        print(f"\n   {base} →  {', '.join(variations)}")

    # Summary
    print("\n\n" + "=" * 70)
    print("📋 SUMMARY: What Makes These Names Better for Peru?")
    print("=" * 70)
    print("""
   1. ✅ Spanish Phonetics
      • Uses natural Spanish syllables (la, de, co, ra, ma...)
      • Prefers open syllables (CV pattern)
      • Avoids difficult consonant clusters

   2. ✅ Peruvian Cultural Elements
      • References Andean heritage (Inti, Pacha, Wari...)
      • Uses Quechua-influenced sounds
      • Includes cultural word roots

   3. ✅ Spanish Conventions
      • Often ends in vowels (sounds complete in Spanish)
      • Uses rolled R (rr) and ll for authenticity
      • Employs diminutives (-ito, -ita) common in Peru

   4. ✅ Pronunciation-Friendly
      • Easy for Spanish speakers to say
      • No awkward English sounds (th, ng, sh...)
      • Follows Spanish stress patterns

   5. ✅ Culturally Resonant
      • Uses Spanish word roots by category
      • References local geography/culture
      • Feels authentic, not foreign

   6. ✅ INDECOPI Compliant
      • Still avoids generic/descriptive terms
      • Maintains distinctiveness
      • Passes all trademark guidelines
    """)

    print("=" * 70)
    print("✨ Try it yourself! Use SpanishBrandNameGenerator in your code")
    print("=" * 70)
    print("""
    from brandy import SpanishBrandNameGenerator

    gen = SpanishBrandNameGenerator()
    names = gen.generate(
        count=20,
        style='hybrid',
        category='technology',
        cultural_weight=0.5
    )
    """)
    print()

if __name__ == "__main__":
    main()
