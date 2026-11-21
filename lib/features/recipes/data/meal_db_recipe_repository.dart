import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../models/recipe.dart';
import 'recipe_api_service.dart';
import 'recipe_repository.dart';

/// TheMealDB-backed repository: DTOs in from the API service, domain models
/// out to the app, technical errors mapped to [AppException] (deck p. 105).
class MealDbRecipeRepository implements RecipeRepository {
  final RecipeApiService _api;

  const MealDbRecipeRepository(this._api);

  @override
  Future<List<Recipe>> getRecipes({String query = '', CancelToken? cancelToken}) async {
    try {
      final meals = await _api.searchMeals(query, cancelToken: cancelToken);
      return [for (final meal in meals) meal.toDomain()];
    } on DioException catch (e) {
      // Cancellation is intentional (new search superseded this one), not an error.
      if (CancelToken.isCancel(e)) rethrow;
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
