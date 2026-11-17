/// Immutable ingredient row: name left, amount right (e.g. "250 g").
class Ingredient {
  final String name;
  final String amount;

  const Ingredient({required this.name, required this.amount});
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
