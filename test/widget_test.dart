import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mobile_meal_planner/features/home/presentation/home_view_model.dart';
import 'package:mobile_meal_planner/features/recipes/data/recipe_repository.dart';
import 'package:mobile_meal_planner/features/recipes/presentation/recipe_card.dart';
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
}
