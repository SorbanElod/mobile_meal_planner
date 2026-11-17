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
        Ingredient(name: 'Chicken breasts', amount: '250 g'),
        Ingredient(name: 'Unsalted butter', amount: '1 tbsp'),
        Ingredient(name: 'Sesame or vegetable oil', amount: '2 tsp'),
        Ingredient(name: 'Fresh ginger', amount: '2 tsp'),
        Ingredient(name: 'Large eggs', amount: '100 g'),
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
        Ingredient(name: 'Salmon fillet', amount: '180 g'),
        Ingredient(name: 'Spinach', amount: '100 g'),
        Ingredient(name: 'Shredded carrot', amount: '50 g'),
        Ingredient(name: 'Lemon', amount: '1/2 pc'),
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
        Ingredient(name: 'Chicken thigh', amount: '300 g'),
        Ingredient(name: 'Bell pepper', amount: '1 pc'),
        Ingredient(name: 'Red onion', amount: '1 pc'),
        Ingredient(name: 'Olive oil', amount: '2 tbsp'),
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
        Ingredient(name: 'Tofu', amount: '150 g'),
        Ingredient(name: 'Broccoli', amount: '120 g'),
        Ingredient(name: 'Soy sauce', amount: '1 tbsp'),
        Ingredient(name: 'Sesame seeds', amount: '1 tsp'),
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
        Ingredient(name: 'Penne', amount: '200 g'),
        Ingredient(name: 'Cherry tomatoes', amount: '100 g'),
        Ingredient(name: 'Parmesan', amount: '30 g'),
        Ingredient(name: 'Basil', amount: '5 leaves'),
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
        Ingredient(name: 'Bread slice', amount: '2 pcs'),
        Ingredient(name: 'Avocado', amount: '1 pc'),
        Ingredient(name: 'Egg', amount: '1 pc'),
        Ingredient(name: 'Chili flakes', amount: '1 pinch'),
      ],
    ),
  ];
}
