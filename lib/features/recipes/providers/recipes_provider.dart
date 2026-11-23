import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/prefs.dart';
import '../data/meal_db_recipe_repository.dart';
import '../data/recipe_api_service.dart';
import '../data/recipe_cache.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';

/// Dependency injection via providers (deck p. 26): the object graph is
/// declared here — no manual wiring in main(), and tests can override
/// [recipeRepositoryProvider] with a fake.
final recipeApiServiceProvider = Provider<RecipeApiService>(
  (ref) => RecipeApiService(DioClient.instance),
);

final recipeCacheProvider = Provider<RecipeCache>(
  (ref) => RecipeCache(ref.watch(sharedPreferencesProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => MealDbRecipeRepository(
    ref.watch(recipeApiServiceProvider),
    ref.watch(recipeCacheProvider),
  ),
);

/// The Home recipe list as async state (deck p. 68): [AsyncValue] carries
/// loading / data / error, so the UI never hand-rolls those flags.
/// An empty data list is the Empty state (deck p. 99–101); `fromCache` marks
/// offline data so the UI can show the offline banner (deck p. 110–111).
class RecipesNotifier extends AsyncNotifier<RecipesResult> {
  static const _debounce = Duration(milliseconds: 300);

  Timer? _debounceTimer;
  CancelToken? _searchToken;
  String _query = '';

  @override
  Future<RecipesResult> build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _searchToken?.cancel('provider disposed');
    });
    return _fetch('');
  }

  /// Manual retry after an error (deck p. 106) — wired to the Retry button.
  Future<void> refresh() => _load(_newToken());

  /// Debounced search (deck p. 117): waits 300 ms after the last keystroke,
  /// and cancels the previous in-flight request so a slow stale response can
  /// never overwrite the newer one (race conditions, deck p. 116).
  void search(String query) {
    _query = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => _load(_newToken()));
  }

  CancelToken _newToken() {
    _searchToken?.cancel('superseded by a newer request');
    return _searchToken = CancelToken();
  }

  Future<void> _load(CancelToken token) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _fetch(_query, token));
    } on DioException {
      // Cancelled by a newer search — keep the current state, show nothing.
    } on AppException catch (e) {
      debugPrint('recipes load failed: ${e.userMessage}');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<RecipesResult> _fetch(String query, [CancelToken? token]) =>
      ref.read(recipeRepositoryProvider).getRecipes(query: query, cancelToken: token);
}

final recipesProvider = AsyncNotifierProvider<RecipesNotifier, RecipesResult>(
  RecipesNotifier.new,
);

/// Full record for one recipe by id — `lookup.php?i=…` (deck p. 86).
/// Used wherever only an id is available, e.g. the Favorites screen.
/// FutureProvider gives loading/data/error for free (deck p. 68).
final recipeDetailsProvider = FutureProvider.family<Recipe?, String>(
  (ref, id) => ref.watch(recipeRepositoryProvider).getRecipeById(id),
);
