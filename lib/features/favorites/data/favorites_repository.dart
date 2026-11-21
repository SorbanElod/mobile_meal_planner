import 'package:shared_preferences/shared_preferences.dart';

/// Single access point for the persisted favorite recipe ids.
/// State management (Riverpod) and persistence (this) are separate concerns
/// that work together (deck p. 12, p. 122–123).
abstract class FavoritesRepository {
  Future<Set<String>> loadFavorites();

  Future<void> saveFavorites(Set<String> ids);
}

/// Key–value storage in SharedPreferences: ideal for a small list of ids
/// (deck p. 125, p. 128). NOT for large/structured data or secrets (p. 126).
class SharedPreferencesFavoritesRepository implements FavoritesRepository {
  static const _key = 'favorite_ids';

  final SharedPreferencesAsync _prefs;

  const SharedPreferencesFavoritesRepository(this._prefs);

  @override
  Future<Set<String>> loadFavorites() async {
    final list = await _prefs.getStringList(_key);
    return list?.toSet() ?? const {};
  }

  @override
  Future<void> saveFavorites(Set<String> ids) =>
      _prefs.setStringList(_key, ids.toList());
}
