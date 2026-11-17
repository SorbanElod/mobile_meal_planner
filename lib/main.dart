import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/home/presentation/home_view_model.dart';
import 'features/recipes/data/recipe_repository.dart';

void main() {
  // Composition root: build the object graph, start the initial load.
  final homeViewModel = HomeViewModel(repository: MockRecipeRepository());
  homeViewModel.loadRecipes();
  runApp(MealPlannerApp(homeViewModel: homeViewModel));
}

class MealPlannerApp extends StatelessWidget {
  final HomeViewModel homeViewModel;

  const MealPlannerApp({super.key, required this.homeViewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const _ClampScrollBehavior(),
      home: HomeScreen(viewModel: homeViewModel),
    );
  }
}

/// Forces clamping (Android-style) overscroll physics on every scrollable,
/// so no list rubber-bands at its ends.
class _ClampScrollBehavior extends MaterialScrollBehavior {
  const _ClampScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
