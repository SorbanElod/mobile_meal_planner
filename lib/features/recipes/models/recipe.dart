/// Immutable ingredient row: name left, scaled amount right (e.g. "250 g"
/// for 2 serves). Amounts are stored per serve so the serves stepper can
/// recompute them.
class Ingredient {
  final String name;
  final double amountPerServe;
  final String unit;

  const Ingredient({
    required this.name,
    required this.amountPerServe,
    required this.unit,
  });

  /// Display amount for [serves] people, e.g. "250 g" or "1.5 tbsp".
  String amountFor(int serves) {
    final value = amountPerServe * serves;
    final formatted = (value % 1 == 0)
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$formatted $unit';
  }
}

/// Data model for a recipe. All fields are final and the constructor is
/// const, so a recipe is plain immutable data that can be passed down
/// through constructors and shared safely.
class Recipe {
  final String id;
  final String title;
  final String mealType; // e.g. "Lunch"
  final int minutes; // e.g. 15
  final String imageUrl;
  final int energyKcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<Ingredient> ingredients;

  const Recipe({
    required this.id,
    required this.title,
    required this.mealType,
    required this.minutes,
    required this.imageUrl,
    required this.energyKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.ingredients,
  });

  /// Shown under the title on the details screen, e.g. "Lunch / 15 mins".
  String get subtitle => '$mealType / $minutes mins';
}
