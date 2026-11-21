import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/meal_db_recipe_repository.dart';
import '../data/recipe_api_service.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';

/// Dependency injection via providers (deck p. 26): the object graph is
/// declared here — no manual wiring in main(), and tests can override
/// [recipeRepositoryProvider] with a fake.
final recipeApiServiceProvider = Provider<RecipeApiService>(
  (ref) => RecipeApiService(DioClient.instance),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => MealDbRecipeRepository(ref.watch(recipeApiServiceProvider)),
);

/// The Home recipe list as async state (deck p. 68): [AsyncValue] carries
/// loading / data / error, so the UI never hand-rolls those flags.
/// An empty data list is the Empty state (deck p. 99–101).
class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() => _fetch('');

  /// Manual retry after an error (deck p. 106) — wired to the Retry button.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(''));
  }

  Future<List<Recipe>> _fetch(String query) =>
      ref.read(recipeRepositoryProvider).getRecipes(query: query);
}

final recipesProvider = AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(
  RecipesNotifier.new,
);
