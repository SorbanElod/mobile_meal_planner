/// Immutable ingredient row. TheMealDB measures are free text ("1.2 kg",
/// "5 thinly sliced", "3/4 cup", "pinch"), so [amountPerServe] is 0 when the
/// measure has no leading number — [amountFor] then returns the raw [unit].
class Ingredient {
  final String name;
  final double amountPerServe;
  final String unit;

  const Ingredient({
    required this.name,
    required this.amountPerServe,
    required this.unit,
  });

  /// Parses a measure like "3/4 cup" → 0.75 + "cup", "1.2 kg" → 1.2 + "kg",
  /// "pinch" → 0 + "pinch" (not numerically scalable).
  factory Ingredient.fromMeasure(String name, String? measure) {
    final text = (measure ?? '').trim();
    final match = _measurePattern.firstMatch(text);
    if (match == null) {
      return Ingredient(name: name, amountPerServe: 0, unit: text);
    }
    return Ingredient(
      name: name,
      amountPerServe: _parseNumber(match.group(1)!),
      unit: match.group(2)!.trim(),
    );
  }

  static final _measurePattern = RegExp(
    r'^(\d+(?:\.\d+)?|\d+\s*/\s*\d+|½|¼|¾)\s*(.*)$',
  );

  static double _parseNumber(String raw) {
    const unicodeFractions = {'½': 0.5, '¼': 0.25, '¾': 0.75};
    if (unicodeFractions.containsKey(raw)) return unicodeFractions[raw]!;
    if (raw.contains('/')) {
      final parts = raw.split('/');
      final numerator = double.tryParse(parts[0].trim()) ?? 0;
      final denominator = double.tryParse(parts[1].trim()) ?? 0;
      return denominator != 0 ? numerator / denominator : 0;
    }
    return double.tryParse(raw) ?? 0;
  }

  /// Display amount for [serves] people, e.g. "250 g" or "1.5 tbsp".
  /// Non-scalable measures ("pinch") are returned verbatim.
  String amountFor(int serves) {
    if (amountPerServe == 0) return unit;
    final value = amountPerServe * serves;
    final formatted = (value % 1 == 0)
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return unit.isEmpty ? formatted : '$formatted $unit';
  }
}

/// Domain model for a recipe. All fields are final and the constructor is
/// const, so a recipe is plain immutable data passed down via constructors.
///
/// TheMealDB provides no time/nutrition values, so those fields are nullable
/// and the UI shows "N/A" rather than a fake 0 (deck p. 76–78).
class Recipe {
  final String id;
  final String title;
  final String? imageUrl;
  final String? category;
  final String? area;
  final int? minutes;
  final int? energyKcal;
  final int? proteinG;
  final int? carbsG;
  final int? fatG;
  final List<Ingredient> ingredients;
  final String? instructions;

  const Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    this.category,
    this.area,
    this.minutes,
    this.energyKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.ingredients = const [],
    this.instructions,
  });

  /// Shown under the title on the details screen, e.g. "Chicken / 15 mins".
  /// Missing parts are simply omitted instead of rendering "null".
  String get subtitle {
    final parts = <String>[
      if (category != null && category!.isNotEmpty) category!,
      if (minutes != null) '$minutes mins',
    ];
    return parts.isEmpty ? 'Recipe' : parts.join(' / ');
  }
}
