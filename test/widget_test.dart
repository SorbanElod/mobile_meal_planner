import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mobile_meal_planner/core/theme/app_theme.dart';
import 'package:mobile_meal_planner/core/widgets/favorite_button.dart';
import 'package:mobile_meal_planner/features/favorites/data/favorites_repository.dart';
import 'package:mobile_meal_planner/features/favorites/providers/favorites_provider.dart';
import 'package:mobile_meal_planner/features/recipes/data/recipe_repository.dart';
import 'package:mobile_meal_planner/features/recipes/models/recipe.dart';
import 'package:mobile_meal_planner/features/recipes/presentation/recipe_card.dart';
import 'package:mobile_meal_planner/features/recipes/presentation/recipe_details_screen.dart';
import 'package:mobile_meal_planner/features/recipes/providers/recipes_provider.dart';
import 'package:mobile_meal_planner/main.dart';

/// In-memory repository for tests — provider overriding (deck p. 26) means
/// no real network in widget tests.
class FakeRecipeRepository implements RecipeRepository {
  static const recipes = <Recipe>[
    Recipe(
      id: '1',
      title: 'Chicken Pasta',
      category: 'Chicken',
      ingredients: [Ingredient(name: 'Pasta', amountPerServe: 100, unit: 'g')],
    ),
    Recipe(id: '2', title: 'Greek Salad', category: 'Salad'),
  ];

  @override
  Future<List<Recipe>> getRecipes({String query = '', CancelToken? cancelToken}) async {
    if (query == 'zzz') return const []; // simulate "no results"
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeById(String id, {CancelToken? cancelToken}) async {
    return recipes.where((r) => r.id == id).firstOrNull;
  }
}

/// In-memory favorites storage for tests — proves the save/load contract
/// without touching platform channels.
class InMemoryFavoritesRepository implements FavoritesRepository {
  Set<String> saved = const {};

  @override
  Future<Set<String>> loadFavorites() async => saved;

  @override
  Future<void> saveFavorites(Set<String> ids) async => saved = ids;
}

Widget wrapApp({FavoritesRepository? favorites}) => ProviderScope(
  overrides: [
    recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
    favoritesRepositoryProvider.overrideWithValue(
      favorites ?? InMemoryFavoritesRepository(),
    ),
  ],
  child: const MealPlannerApp(),
);

void main() {
  testWidgets('Home shows loading, then all recipes', (tester) async {
    await tester.pumpWidget(wrapApp());
    expect(find.byType(RecipeCard), findsNothing); // still loading

    await tester.pumpAndSettle();
    expect(find.text("Today's Progress"), findsOneWidget);
    expect(find.byType(RecipeCard), findsWidgets); // visible ones built lazily
  });

  testWidgets('No overflow at 360 px width', (tester) async {
    // 360x800 logical px (physical 1080x2400 at dpr 3.0)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    await tester.pumpWidget(wrapApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Tap recipe card opens details, back returns home', (tester) async {
    await tester.pumpWidget(wrapApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RecipeCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Chicken Pasta'), findsOneWidget); // details of the tapped recipe
    expect(find.text('Chicken'), findsOneWidget); // subtitle from category

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsWidgets); // back on Home
    expect(tester.takeException(), isNull); // navigation never crashed
  });

  testWidgets('Details shows recipe data, stepper scales, back pops', (tester) async {
    const recipe = Recipe(
      id: '1',
      title: 'Ramen',
      category: 'Noodles',
      minutes: 15,
      energyKcal: 100,
      proteinG: 15,
      carbsG: 58,
      fatG: 20,
      ingredients: [
        Ingredient(name: 'Chicken breasts', amountPerServe: 125, unit: 'g'),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(
            InMemoryFavoritesRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailsScreen(recipe: recipe),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Ramen'), findsOneWidget);
    expect(find.text('Noodles / 15 mins'), findsOneWidget);
    expect(find.text('100 k'), findsOneWidget);
    expect(find.text('Chicken breasts'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
    expect(find.textContaining('2 serves'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.textContaining('3 serves'), findsOneWidget);
    expect(find.text('375 g'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('Favorite toggle is shared: card heart → Favorites tab', (tester) async {
    final favorites = InMemoryFavoritesRepository();
    await tester.pumpWidget(wrapApp(favorites: favorites));
    await tester.pumpAndSettle();

    // Heart on the first card starts empty.
    expect(find.byIcon(Icons.favorite), findsNothing);
    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget); // filled heart
    expect(favorites.saved, contains('1')); // persisted via the repository

    // Switch to the Favorites tab — the same shared state shows the recipe.
    // (Cards are image-only per the Figma design, so assert on the card widget.)
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Untoggle from the Favorites card → empty state appears.
    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('No favorites yet'), findsOneWidget);
    expect(favorites.saved, isEmpty);
  });
}
