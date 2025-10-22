"""
Spanish/Peruvian-Enhanced Brand Name Generator Configuration

This module contains Spanish phonetic patterns and Peruvian cultural elements
for generating brand names that resonate with Spanish-speaking audiences in Peru.
"""

# Spanish vowels (standard 5, but Quechua influence sometimes reduces to 3: a, i, u)
SPANISH_VOWELS = ['a', 'e', 'i', 'o', 'u']
QUECHUA_VOWELS = ['a', 'i', 'u']  # Influenced by Quechua phonology

# Spanish-friendly consonants (excluding problematic ones)
SPANISH_CONSONANTS = [
    'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm',
    'n', 'p', 'r', 's', 't', 'v', 'y', 'z'
]

# Natural Spanish consonant clusters
SPANISH_CLUSTERS = [
    # Most common and natural in Spanish
    'br', 'bl',  # bri-llo, blan-co
    'cr', 'cl',  # cre-ar, cla-ro
    'dr',        # dra-ma
    'fr', 'fl',  # fres-co, flo-ra
    'gr', 'gl',  # gran-de, glo-ria
    'pr', 'pl',  # pri-ma, pla-no
    'tr',        # tra-ba-jo

    # Spanish-specific sounds
    'ch',        # chi-le (single sound in Spanish)
    'll',        # lla-ma (single sound, like English 'y')
    'rr',        # pe-rro (strong rolled R)
]

# Syllable patterns that sound natural in Spanish
# Spanish prefers open syllables (CV) over closed ones
SPANISH_SYLLABLE_PATTERNS = [
    'CV',   # Most common: ma, no, si (60% of Spanish syllables)
    'CVC',  # Common: mar, sol, pan
    'V',    # Vowel alone: a-mor, e-ra
    'VC',   # Less common: ar-te, es-tar
]

# Peruvian/Andean cultural prefixes (evocative of heritage)
PERUVIAN_PREFIXES = [
    # Andean/Inca inspired
    'inti',     # Sun god
    'pacha',    # Earth/world
    'illa',     # Light/sacred
    'killa',    # Moon
    'wari',     # Ancient culture
    'inca',     # Imperial heritage

    # Modern Peruvian feel
    'andes',    # Mountain range
    'cusco',    # Ancient capital
    'lima',     # Capital city
    'pisco',    # National drink

    # Spanish-friendly evocative
    'alma',     # soul
    'vida',     # life
    'luz',      # light
    'sol',      # sun
    'mar',      # sea
    'oro',      # gold
    'cielo',    # sky
    'tierra',   # earth
    'fuego',    # fire
    'viento',   # wind
]

# Spanish-resonant suffixes
SPANISH_SUFFIXES = [
    # Common Spanish endings
    'ito', 'ita',   # diminutives (very Peruvian!)
    'azo', 'aza',   # augmentatives
    'illo', 'illa', # diminutives
    'on', 'ona',    # augmentatives

    # Business-friendly endings
    'ia', 'io',     # tec-no-lo-gí-a
    'ar', 'al',     # pol-ar, digit-al
    'ero', 'era',   # profession
    'ado', 'ada',   # past participle feel

    # Modern/tech endings that work in Spanish
    'tech', 'tek',  # anglicisms accepted in tech
    'lab', 'hub',   # anglicisms in startup culture
    'app', 'net',   # tech terms
    'pro', 'plus',  # commercial terms

    # Natural Spanish sounds
    'os', 'as',     # plural feel
    'ez', 'es',     # surname-like (Lopez, Torres)
    'ez', 'is',     # elegant endings
]

# Common Spanish syllables (from frequency analysis)
# These appear most often in Spanish and sound very natural
COMMON_SPANISH_SYLLABLES = [
    # High frequency
    'la', 'de', 'co', 'ra', 'ma', 'na', 'ta', 'sa', 'ca', 'pa',
    'li', 'do', 'to', 'te', 'ro', 'mi', 'se', 'da', 'le', 'ba',

    # Medium frequency but nice sounding
    'no', 'po', 'ti', 'so', 'mo', 'cha', 'go', 'bo', 'fi', 'za',
    'lu', 'nu', 'va', 'ja', 'rio', 'chi', 'vi', 'llo', 'ki', 'ya',

    # Andean influence
    'wa', 'ku', 'qa', 'tu', 'yu', 'mu', 'pa', 'ka'
]

# Words/patterns to AVOID in Spanish/Peru
SPANISH_FORBIDDEN_PATTERNS = [
    # Spanish bad words (parcial list - be careful)
    'puta', 'puto', 'mierda', 'caca', 'culo', 'pedo',
    'gato', 'paja', 'huevo', 'polla', 'concha',

    # Awkward in Spanish
    'kkk',  # has negative connotations
    'qq',   # unnatural doubling
    'xx',   # rare in Spanish

    # Too English-sounding (may alienate Spanish speakers)
    'xzw', 'pfft', 'tsk',

    # Generic/descriptive (INDECOPI will reject)
    'super', 'mega', 'ultra', 'hiper',
    'mejor', 'bueno', 'grande', 'nuevo',
    'max', 'plus', 'top', 'best',
    'perfecto', 'premium', 'oro', 'plata',
]

# Phonetic combinations that DON'T work well in Spanish
AVOID_CLUSTERS = [
    'ng', 'nk',     # English sounds, awkward in Spanish
    'sh', 'zh',     # doesn't exist in standard Spanish
    'th',           # English sound (Spain has this, but not Latin America)
    'gb', 'gd',     # unnatural
    'pf', 'ps',     # rare, awkward (except in technical terms)
    'tz', 'dz',     # rare
    'vr', 'vl',     # difficult
]

# Culturally-resonant word roots (Spanish)
SPANISH_WORD_ROOTS = {
    'technology': ['tecno', 'digi', 'ciber', 'virtual', 'data', 'info'],
    'food': ['sabor', 'gusto', 'cocina', 'mesa', 'rico', 'fresco'],
    'nature': ['verde', 'eco', 'natura', 'bio', 'tierra', 'vida'],
    'energy': ['poder', 'fuerza', 'energia', 'activo', 'vivo', 'dina'],
    'creativity': ['arte', 'crea', 'idea', 'inspira', 'imagina', 'vision'],
    'luxury': ['fino', 'elegante', 'estilo', 'clase', 'royal', 'elite'],
    'speed': ['rapido', 'veloz', 'turbo', 'flash', 'pronto', 'express'],
    'quality': ['calidad', 'fino', 'excel', 'premi', 'select', 'superior'],
}

# Successful Peruvian brand patterns (for inspiration)
PERUVIAN_BRAND_PATTERNS = {
    'simple_memorable': ['Inca Kola', 'Belcorp', 'Yanbal', 'Gloria', 'Alicorp'],
    'cultural': ['Cusqueña', 'Pilsen', 'Cristal'],
    'descriptive': ['Wong', 'Plaza Vea', 'Metro'],
    'modern': ['Rappi', 'Platanitos', 'Topitop'],
}

# Tips for Spanish brand naming
SPANISH_NAMING_TIPS = """
1. Prefer open syllables (CV pattern): ma-ri-a, to-yo-ta
2. Use rolled R when possible for impact: te-RRa, co-RRo
3. End with vowels (sounds complete in Spanish): Tele-fóni-ca, Amé-ri-ca
4. Use diminutives for friendliness: -ito/-ita (very Peruvian!)
5. Avoid consonant clusters that don't exist in Spanish
6. Make it phonetic - spell as you pronounce
7. Consider Quechua influence in Peru (Andean sounds)
8. Use double L (ll) and RR for Spanish authenticity
9. Reference cultural heritage when appropriate (Inca, Andes, etc.)
10. Test pronunciation - if Spanish speakers stumble, revise
"""
