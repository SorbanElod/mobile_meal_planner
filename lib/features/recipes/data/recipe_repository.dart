import '../models/recipe.dart';

/// Single data-access point for recipes. Widgets only ever see this
/// interface and `Future<List<Recipe>>`, so the source (mock now,
/// API/database later) can change without touching the UI.
abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes();
}

/// Sprint 1 mock: returns hardcoded recipes after a short delay to
/// simulate network latency. Mock data lives here, never in widgets.
class MockRecipeRepository implements RecipeRepository {
  static const _latency = Duration(milliseconds: 600);

  @override
  Future<List<Recipe>> getRecipes() async {
    await Future<void>.delayed(_latency);
    return _mockRecipes;
  }

  static const _mockRecipes = <Recipe>[
    Recipe(
      id: 'ramen',
      title: 'Ramen',
      mealType: 'Lunch',
      minutes: 15,
      imageUrl: 'assets/images/ramen.jpg',
      energyKcal: 100,
      proteinG: 15,
      carbsG: 58,
      fatG: 20,
      ingredients: [
        Ingredient(name: 'Chicken breasts', amountPerServe: 125, unit: 'g'),
        Ingredient(name: 'Unsalted butter', amountPerServe: 0.5, unit: 'tbsp'),
        Ingredient(name: 'Sesame or vegetable oil', amountPerServe: 1, unit: 'tsp'),
        Ingredient(name: 'Fresh ginger', amountPerServe: 1, unit: 'tsp'),
        Ingredient(name: 'Large eggs', amountPerServe: 50, unit: 'g'),
      ],
    ),
    Recipe(
      id: 'salmon-bowl',
      title: 'Salmon Salad Bowl',
      mealType: 'Dinner',
      minutes: 20,
      imageUrl: 'assets/images/salmon_bowl.jpg',
      energyKcal: 320,
      proteinG: 28,
      carbsG: 22,
      fatG: 12,
      ingredients: [
        Ingredient(name: 'Salmon fillet', amountPerServe: 90, unit: 'g'),
        Ingredient(name: 'Spinach', amountPerServe: 50, unit: 'g'),
        Ingredient(name: 'Shredded carrot', amountPerServe: 25, unit: 'g'),
        Ingredient(name: 'Lemon', amountPerServe: 0.5, unit: 'pc'),
      ],
    ),
    Recipe(
      id: 'chicken-skewers',
      title: 'Chicken Skewers',
      mealType: 'Dinner',
      minutes: 25,
      imageUrl: 'assets/images/skewers.jpg',
      energyKcal: 410,
      proteinG: 35,
      carbsG: 30,
      fatG: 14,
      ingredients: [
        Ingredient(name: 'Chicken thigh', amountPerServe: 150, unit: 'g'),
        Ingredient(name: 'Bell pepper', amountPerServe: 0.5, unit: 'pc'),
        Ingredient(name: 'Red onion', amountPerServe: 0.5, unit: 'pc'),
        Ingredient(name: 'Olive oil', amountPerServe: 1, unit: 'tbsp'),
      ],
    ),
    Recipe(
      id: 'veggie-stir-fry',
      title: 'Veggie Stir-Fry',
      mealType: 'Lunch',
      minutes: 15,
      imageUrl: 'assets/images/salmon_bowl.jpg',
      energyKcal: 260,
      proteinG: 9,
      carbsG: 38,
      fatG: 8,
      ingredients: [
        Ingredient(name: 'Tofu', amountPerServe: 75, unit: 'g'),
        Ingredient(name: 'Broccoli', amountPerServe: 60, unit: 'g'),
        Ingredient(name: 'Soy sauce', amountPerServe: 0.5, unit: 'tbsp'),
        Ingredient(name: 'Sesame seeds', amountPerServe: 0.5, unit: 'tsp'),
      ],
    ),
    Recipe(
      id: 'pasta-primavera',
      title: 'Pasta Primavera',
      mealType: 'Dinner',
      minutes: 20,
      imageUrl: 'assets/images/skewers.jpg',
      energyKcal: 480,
      proteinG: 14,
      carbsG: 72,
      fatG: 12,
      ingredients: [
        Ingredient(name: 'Penne', amountPerServe: 100, unit: 'g'),
        Ingredient(name: 'Cherry tomatoes', amountPerServe: 50, unit: 'g'),
        Ingredient(name: 'Parmesan', amountPerServe: 15, unit: 'g'),
        Ingredient(name: 'Basil', amountPerServe: 2.5, unit: 'leaves'),
      ],
    ),
    Recipe(
      id: 'avocado-toast',
      title: 'Avocado Toast',
      mealType: 'Breakfast',
      minutes: 10,
      imageUrl: 'assets/images/ramen.jpg',
      energyKcal: 290,
      proteinG: 8,
      carbsG: 30,
      fatG: 16,
      ingredients: [
        Ingredient(name: 'Bread slice', amountPerServe: 1, unit: 'pc'),
        Ingredient(name: 'Avocado', amountPerServe: 0.5, unit: 'pc'),
        Ingredient(name: 'Egg', amountPerServe: 0.5, unit: 'pc'),
        Ingredient(name: 'Chili flakes', amountPerServe: 0.5, unit: 'pinch'),
      ],
    ),
  ];
}
