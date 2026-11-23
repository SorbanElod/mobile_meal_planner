import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:mobile_meal_planner/core/errors/app_exception.dart';
import 'package:mobile_meal_planner/features/recipes/data/dto/meal_dto.dart';
import 'package:mobile_meal_planner/features/recipes/data/meal_db_recipe_repository.dart';
import 'package:mobile_meal_planner/features/recipes/data/recipe_api_service.dart';
import 'package:mobile_meal_planner/features/recipes/data/recipe_cache.dart';

/// API service stub: can succeed with a fixed list or fail like a network error.
class _StubApiService extends RecipeApiService {
  _StubApiService({this.meals = const [], this.error}) : super(Dio());

  final List<MealDto> meals;
  final DioException? error;

  @override
  Future<List<MealDto>> searchMeals(String query, {CancelToken? cancelToken}) async {
    final e = error;
    if (e != null) throw e;
    return meals;
  }
}

class _MemoryCache extends RecipeCache {
  List<MealDto>? stored;
  int writes = 0;

  _MemoryCache([this.stored]) : super(SharedPreferencesAsync());

  @override
  Future<List<MealDto>?> read() async => stored;

  @override
  Future<void> write(List<MealDto> meals) async {
    writes++;
    stored = meals;
  }
}

const _meal = <String, dynamic>{
  'idMeal': '52772',
  'strMeal': 'Teriyaki Chicken Casserole',
  'strCategory': 'Chicken',
  'strIngredient1': 'soy sauce',
  'strMeasure1': '3/4 cup',
};

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  test('successful response is mapped AND written to the cache', () async {
    final cache = _MemoryCache();
    final repo = MealDbRecipeRepository(
      _StubApiService(meals: [MealDto.fromJson(_meal)]),
      cache,
    );

    final result = await repo.getRecipes();

    expect(result.recipes, hasLength(1));
    expect(result.recipes.first.title, 'Teriyaki Chicken Casserole');
    expect(result.fromCache, isFalse);
    expect(cache.writes, 1); // last good response cached
  });

  test('network error falls back to cache and is flagged fromCache (offline banner)', () async {
    final cache = _MemoryCache([MealDto.fromJson(_meal)]);
    final repo = MealDbRecipeRepository(
      _StubApiService(
        error: DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: ''),
        ),
      ),
      cache,
    );

    final result = await repo.getRecipes();
    expect(result.fromCache, isTrue); // UI shows the offline banner
    expect(result.recipes.first.id, '52772'); // served from cache, not an error
  });

  test('offline fallback filters the cache by the search query', () async {
    final cache = _MemoryCache([
      MealDto.fromJson(_meal),
      MealDto.fromJson({..._meal, 'idMeal': '1', 'strMeal': 'Beef Stew'}),
    ]);
    final repo = MealDbRecipeRepository(
      _StubApiService(
        error: DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: ''),
        ),
      ),
      cache,
    );

    final result = await repo.getRecipes(query: 'beef');
    expect(result.fromCache, isTrue);
    expect(result.recipes, hasLength(1));
    expect(result.recipes.first.title, 'Beef Stew');
  });

  test('network error with empty cache throws a user-friendly AppException', () async {
    final repo = MealDbRecipeRepository(
      _StubApiService(
        error: DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: ''),
        ),
      ),
      _MemoryCache(),
    );

    expect(
      repo.getRecipes(),
      throwsA(
        isA<NetworkException>().having(
          (e) => e.userMessage,
          'userMessage',
          contains('offline'),
        ),
      ),
    );
  });

  test('cancellation is rethrown, never swallowed as an error or cache hit', () async {
    final cache = _MemoryCache([MealDto.fromJson(_meal)]);
    final repo = MealDbRecipeRepository(
      _StubApiService(
        error: DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: ''),
        ),
      ),
      cache,
    );

    expect(repo.getRecipes(), throwsA(isA<DioException>()));
  });
}
