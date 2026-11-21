import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_meal_planner/features/recipes/data/dto/meal_dto.dart';
import 'package:mobile_meal_planner/features/recipes/models/recipe.dart';

/// Realistic TheMealDB `lookup.php?i=52772`-style payload (trimmed to 20
/// ingredient slots), including null/empty fields — guards the null-safety
/// rules from deck p. 76–79.
const _realMealJson = <String, dynamic>{
  'idMeal': '52772',
  'strMeal': 'Teriyaki Chicken Casserole',
  'strMealAlternate': null,
  'strCategory': 'Chicken',
  'strArea': 'Japanese',
  'strInstructions': 'Preheat oven to 350 F. Mix everything. Bake 35 minutes.',
  'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvywsp.jpg',
  'strIngredient1': 'soy sauce',
  'strMeasure1': '3/4 cup',
  'strIngredient2': 'water',
  'strMeasure2': '1/2 cup',
  'strIngredient3': 'chicken breasts',
  'strMeasure3': '2',
  'strIngredient4': 'sesame seeds',
  'strMeasure4': '1 pinch',
  'strIngredient5': null, // API sends null for unused slots
  'strMeasure5': null,
  'strIngredient6': '   ', // whitespace-only must be skipped too
  'strMeasure6': ' ',
};

void main() {
  test('MealDto.fromJson parses fields and skips empty ingredient slots', () {
    final dto = MealDto.fromJson(_realMealJson);

    expect(dto.idMeal, '52772');
    expect(dto.strMeal, 'Teriyaki Chicken Casserole');
    expect(dto.strCategory, 'Chicken');
    expect(dto.strArea, 'Japanese');
    expect(dto.strMealThumb, contains('themealdb.com'));
    expect(dto.ingredients, hasLength(4)); // null/blank slots skipped
    expect(dto.ingredients.first.name, 'soy sauce');
  });

  test('measures parse into scalable amounts: "3/4 cup" → 0.75 cup', () {
    final dto = MealDto.fromJson(_realMealJson);
    final soySauce = dto.ingredients.first;

    expect(soySauce.amountPerServe, 0.75);
    expect(soySauce.unit, 'cup');
    expect(soySauce.amountFor(1), '0.75 cup');
    expect(soySauce.amountFor(2), '1.5 cup');

    final chicken = dto.ingredients[2]; // "2" with no unit
    expect(chicken.amountPerServe, 2);
    expect(chicken.amountFor(3), '6');

    final sesame = dto.ingredients[3]; // "1 pinch" → scalable number + unit
    expect(sesame.amountFor(2), '2 pinch');
  });

  test('non-numeric measures are kept verbatim, not scaled to 0', () {
    final ingredient = Ingredient.fromMeasure('salt', 'to taste');
    expect(ingredient.amountPerServe, 0);
    expect(ingredient.amountFor(4), 'to taste');
  });

  test('fromJson rejects records without id/name (deck p. 78)', () {
    expect(
      () => MealDto.fromJson({'idMeal': '', 'strMeal': 'X'}),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => MealDto.fromJson({'strMeal': 'X'}),
      throwsA(isA<FormatException>()),
    );
  });

  test('null optional fields become null (placeholder in UI), not fake values', () {
    final dto = MealDto.fromJson({..._realMealJson, 'strMealThumb': null});
    final recipe = dto.toDomain();

    expect(recipe.imageUrl, isNull);
    expect(recipe.energyKcal, isNull); // TheMealDB has no nutrition → N/A in UI
    expect(recipe.minutes, isNull);
    expect(recipe.id, '52772');
    expect(recipe.title, 'Teriyaki Chicken Casserole');
    expect(recipe.category, 'Chicken');
    expect(recipe.ingredients, hasLength(4));
    expect(recipe.instructions, isNotNull);
  });

  test('Recipe.subtitle omits missing parts instead of rendering null', () {
    const withAll = Recipe(id: '1', title: 'A', category: 'Chicken', minutes: 15);
    const categoryOnly = Recipe(id: '2', title: 'B', category: 'Pasta');
    const nothing = Recipe(id: '3', title: 'C');

    expect(withAll.subtitle, 'Chicken / 15 mins');
    expect(categoryOnly.subtitle, 'Pasta');
    expect(nothing.subtitle, 'Recipe');
  });
}
