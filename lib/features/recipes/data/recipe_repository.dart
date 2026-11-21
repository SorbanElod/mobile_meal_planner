import 'package:dio/dio.dart';

import '../models/recipe.dart';

/// Single data-access point for recipes (deck p. 85). The UI/providers only
/// ever see this interface, so the source (TheMealDB now, own backend or
/// local cache later) can change without touching presentation code.
abstract class RecipeRepository {
  /// Searches recipes; an empty [query] returns the default list.
  /// [cancelToken] lets the caller abort an in-flight search (deck p. 63).
  Future<List<Recipe>> getRecipes({String query = '', CancelToken? cancelToken});

  /// Full record for one recipe — e.g. to resolve a favorited id.
  Future<Recipe?> getRecipeById(String id, {CancelToken? cancelToken});
}
