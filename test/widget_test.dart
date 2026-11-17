import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mobile_meal_planner/core/theme/app_theme.dart';
import 'package:mobile_meal_planner/features/home/presentation/home_view_model.dart';
import 'package:mobile_meal_planner/features/recipes/data/recipe_repository.dart';
import 'package:mobile_meal_planner/features/recipes/models/recipe.dart';
import 'package:mobile_meal_planner/features/recipes/presentation/recipe_card.dart';
import 'package:mobile_meal_planner/features/recipes/presentation/recipe_details_screen.dart';
import 'package:mobile_meal_planner/main.dart';

void main() {
  testWidgets('Home shows loading, then all mock recipes', (tester) async {
    final viewModel = HomeViewModel(repository: MockRecipeRepository());
    viewModel.loadRecipes();
    await tester.pumpWidget(MealPlannerApp(homeViewModel: viewModel));
    expect(find.byType(RecipeCard), findsNothing); // still loading

    await tester.pumpAndSettle();
    expect(find.text("Today's Progress"), findsOneWidget);
    expect(viewModel.recipes, hasLength(6)); // all mock recipes loaded
    expect(find.byType(RecipeCard), findsWidgets); // visible ones built lazily
  });

  testWidgets('No overflow at 360 px width', (tester) async {
    // 360x800 logical px (physical 1080x2400 at dpr 3.0)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    final viewModel = HomeViewModel(repository: MockRecipeRepository());
    viewModel.loadRecipes();
    await tester.pumpWidget(MealPlannerApp(homeViewModel: viewModel));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Tap recipe card opens details, back returns home', (tester) async {
    final viewModel = HomeViewModel(repository: MockRecipeRepository());
    viewModel.loadRecipes();
    await tester.pumpWidget(MealPlannerApp(homeViewModel: viewModel));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RecipeCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Ramen'), findsOneWidget); // details of the tapped recipe
    expect(find.text('Lunch / 15 mins'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsWidgets); // back on Home
    expect(tester.takeException(), isNull); // navigation never crashed
  });

  testWidgets('Details shows recipe data, stepper scales, back pops', (tester) async {
    const recipe = Recipe(
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
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
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
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Ramen'), findsOneWidget);
    expect(find.text('Lunch / 15 mins'), findsOneWidget);
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
}
