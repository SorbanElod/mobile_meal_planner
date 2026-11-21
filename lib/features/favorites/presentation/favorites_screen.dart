import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../recipes/models/recipe.dart';
import '../../recipes/presentation/recipe_card.dart';
import '../../recipes/presentation/recipe_details_screen.dart';
import '../providers/favorites_provider.dart';

/// Favorites tab: lists the recipes whose ids are persisted locally, resolved
/// to full records via `favoriteRecipesProvider`. Has its own loading / error
/// / empty states (deck p. 99–103 — "empty favorites" is NOT the same message
/// as "no search results").
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(favoriteRecipesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Favorites', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: _buildList(context, ref, recipesAsync)),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Recipe>> recipesAsync,
  ) {
    return recipesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error is AppException ? error.userMessage : 'Something went wrong',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => ref.invalidate(favoriteRecipesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No favorites yet.\nTap the heart on a recipe to save it here.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RecipeCard(
                recipe: recipe,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailsScreen(recipe: recipe),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
