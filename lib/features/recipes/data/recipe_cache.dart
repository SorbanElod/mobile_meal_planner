import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'dto/meal_dto.dart';

/// JSON cache of the last successful API response in SharedPreferences
/// (deck p. 90, p. 132: cached recipes are re-fetchable data, so a small JSON
/// blob is enough — no database needed). Read on network failure so the app
/// keeps working offline (deck p. 110–111).
class RecipeCache {
  static const _key = 'cached_meals';

  final SharedPreferencesAsync _prefs;

  const RecipeCache(this._prefs);

  /// Returns the cached meals, or null when there is no valid cache.
  Future<List<MealDto>?> read() async {
    final json = await _prefs.getString(_key);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return null;
      return [
        for (final meal in decoded) MealDto.fromJson(meal as Map<String, dynamic>),
      ];
    } on FormatException {
      return null; // corrupt cache → treat as missing
    } on TypeError {
      return null;
    }
  }

  /// Stores the raw response maps; never throws into the caller's load path.
  Future<void> write(List<MealDto> meals) async {
    try {
      await _prefs.setString(
        _key,
        jsonEncode([for (final meal in meals) meal.raw]),
      );
    } on Exception {
      // Cache write failure must not fail the recipe load.
    }
  }
}
