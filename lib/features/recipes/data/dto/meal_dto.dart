import '../../models/recipe.dart';

/// DTO mirroring the raw TheMealDB JSON (deck p. 72). The UI never sees these
/// API field names — [toDomain] maps them onto the [Recipe] domain model, so
/// swapping the backend later only touches this file and its mapper.
///
/// Null-safety (deck p. 76–78): missing/empty optional fields become null;
/// a record without idMeal/strMeal is rejected as invalid.
class MealDto {
  /// Original JSON map, kept so the offline cache can store raw responses.
  final Map<String, dynamic> raw;
  final String idMeal;
  final String strMeal;
  final String? strMealThumb;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final List<Ingredient> ingredients;

  const MealDto({
    required this.raw,
    required this.idMeal,
    required this.strMeal,
    this.strMealThumb,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    required this.ingredients,
  });

  factory MealDto.fromJson(Map<String, dynamic> json) {
    final id = json['idMeal'];
    final name = json['strMeal'];
    // id + name are required for safe identification (deck p. 78).
    if (id is! String || id.isEmpty || name is! String || name.isEmpty) {
      throw const FormatException('Meal record is missing idMeal/strMeal');
    }

    // Ingredients/measures come as 20 parallel fields; empty ones are null.
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      if (ingredient is! String || ingredient.trim().isEmpty) continue;
      final measure = json['strMeasure$i'];
      ingredients.add(
        Ingredient.fromMeasure(
          ingredient.trim(),
          measure is String ? measure : null,
        ),
      );
    }

    return MealDto(
      raw: json,
      idMeal: id,
      strMeal: name,
      strMealThumb: _asString(json['strMealThumb']),
      strCategory: _asString(json['strCategory']),
      strArea: _asString(json['strArea']),
      strInstructions: _asString(json['strInstructions']),
      ingredients: ingredients,
    );
  }

  static String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null; // missing or empty → null, UI falls back to a placeholder
  }

  /// Maps the DTO onto the app's domain model.
  Recipe toDomain() => Recipe(
    id: idMeal,
    title: strMeal,
    imageUrl: strMealThumb,
    category: strCategory,
    area: strArea,
    // TheMealDB provides no time/nutrition → stays null, UI shows "N/A".
    ingredients: ingredients,
    instructions: strInstructions,
  );
}
