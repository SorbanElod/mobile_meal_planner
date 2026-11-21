import 'package:dio/dio.dart';

import 'dto/meal_dto.dart';

/// Thin HTTP layer (deck p. 86): knows the endpoints and query params and
/// returns DTOs. All Dio configuration lives in `DioClient`; errors are
/// rethrown here and mapped to [AppException] by the repository.
class RecipeApiService {
  final Dio _dio;

  const RecipeApiService(this._dio);

  /// `search.php?s=…` — an empty query returns the default list, and
  /// `{"meals": null}` means "no results", which is NOT an error (deck p. 101).
  Future<List<MealDto>> searchMeals(String query, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      'search.php',
      queryParameters: {'s': query},
      cancelToken: cancelToken,
    );
    return _parseMeals(response.data);
  }

  /// `lookup.php?i=…` — the full record for a single meal.
  Future<MealDto?> lookupMeal(String id, {CancelToken? cancelToken}) async {
    final response = await _dio.get(
      'lookup.php',
      queryParameters: {'i': id},
      cancelToken: cancelToken,
    );
    final meals = _parseMeals(response.data);
    return meals.isEmpty ? null : meals.first;
  }

  List<MealDto> _parseMeals(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected API response: not a JSON object');
    }
    final meals = data['meals'];
    if (meals == null) return const [];
    if (meals is! List) {
      throw const FormatException('Unexpected API response: "meals" is not a list');
    }
    return [
      for (final meal in meals) MealDto.fromJson(meal as Map<String, dynamic>),
    ];
  }
}
