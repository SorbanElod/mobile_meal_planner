import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../models/recipe.dart';
import 'recipe_api_service.dart';
import 'recipe_cache.dart';
import 'recipe_repository.dart';

/// TheMealDB-backed repository: DTOs in from the API service, domain models
/// out to the app, technical errors mapped to [AppException] (deck p. 105).
///
/// Cache strategy: Network First (deck p. 91) — a successful response is
/// written to [RecipeCache]; on network/timeout failure the cached list is
/// returned so the app keeps working offline (deck p. 110).
class MealDbRecipeRepository implements RecipeRepository {
  final RecipeApiService _api;
  final RecipeCache? _cache;

  const MealDbRecipeRepository(this._api, [this._cache]);

  @override
  Future<RecipesResult> getRecipes({String query = '', CancelToken? cancelToken}) async {
    try {
      final meals = await _api.searchMeals(query, cancelToken: cancelToken);
      await _cache?.write(meals); // remember the last good response
      return RecipesResult([for (final meal in meals) meal.toDomain()]);
    } on DioException catch (e) {
      // Cancellation is intentional (a newer search superseded this one).
      if (CancelToken.isCancel(e)) rethrow;
      final cached = await _cache?.read();
      if (cached != null && cached.isNotEmpty) {
        // Offline fallback (deck p. 110): serve the cache, filtered by the
        // query client-side so search stays coherent without a network.
        final q = query.trim().toLowerCase();
        final filtered = q.isEmpty
            ? cached
            : cached
                  .where((m) => m.strMeal.toLowerCase().contains(q))
                  .toList();
        return RecipesResult(
          [for (final meal in filtered) meal.toDomain()],
          fromCache: true,
        );
      }
      throw AppException.fromDio(e);
    } on FormatException {
      throw AppException.parse();
    }
  }

  @override
  Future<Recipe?> getRecipeById(String id, {CancelToken? cancelToken}) async {
    try {
      final meal = await _api.lookupMeal(id, cancelToken: cancelToken);
      return meal?.toDomain();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw AppException.fromDio(e);
    } on FormatException {
      throw AppException.parse();
    }
  }
}
