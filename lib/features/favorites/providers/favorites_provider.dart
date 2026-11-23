import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs.dart';
import '../../recipes/models/recipe.dart';
import '../../recipes/providers/recipes_provider.dart';
import '../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => SharedPreferencesFavoritesRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

/// The one shared favorites state for the whole app (Single Source of Truth,
/// deck p. 94): Home cards, Recipe Details and the Favorites screen all watch
/// this provider, so a toggle on one screen is instantly visible everywhere.
/// Initial value is loaded from local storage → favorites survive restarts.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() =>
      ref.watch(favoritesRepositoryProvider).loadFavorites();

  /// Optimistic update (deck p. 112–113): the heart turns red immediately,
  /// the save happens in the background, and a failed save rolls the UI back.
  /// Favorites are the textbook optimistic case — quickly revertible, no
  /// serious consequences.
  Future<void> toggle(String recipeId) async {
    final current = state.value ?? const <String>{};
    final next = Set<String>.from(current);
    if (next.contains(recipeId)) {
      next.remove(recipeId);
    } else {
      next.add(recipeId);
    }
    state = AsyncValue.data(next);
    try {
      await ref.read(favoritesRepositoryProvider).saveFavorites(next);
    } on Exception {
      state = AsyncValue.data(current); // rollback on persistence failure
    }
  }

  bool isFavorite(String recipeId) => state.value?.contains(recipeId) ?? false;
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Resolves the favorited ids to full recipes via `lookup.php?i=…` — used by
/// the Favorites screen, where only ids are stored locally.
final favoriteRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final ids = await ref.watch(favoritesProvider.future);
  final recipes = await Future.wait(
    ids.map((id) => ref.watch(recipeDetailsProvider(id).future)),
  );
  return recipes.whereType<Recipe>().toList();
});
