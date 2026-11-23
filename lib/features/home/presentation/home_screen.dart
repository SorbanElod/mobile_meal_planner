import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../recipes/data/recipe_repository.dart';
import '../../recipes/models/recipe.dart';
import '../../recipes/presentation/recipe_card.dart';
import '../../recipes/presentation/recipe_details_screen.dart';
import '../../recipes/providers/recipes_provider.dart';
import 'widgets/progress_card.dart';

/// Home screen: header, progress card, scrollable recipe list, bottom nav.
/// Renders [recipesProvider]'s AsyncValue (loading / error / empty / success)
/// and forwards actions (retry, open details) — it never talks to the data
/// layer directly.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Ephemeral state: only this widget's bottom nav and search field use it
  // (deck p. 10) — the results themselves live in recipesProvider.
  int _selectedTabIndex = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildBody(recipesAsync),
        ),
      ),
      bottomNavigationBar: _buildNav(),
    );
  }

  /// Tab 0 = Home, tab 4 = Favorites; the other tabs are placeholders.
  Widget _buildBody(AsyncValue<RecipesResult> recipesAsync) {
    if (_selectedTabIndex == 4) return const FavoritesScreen();
    if (_selectedTabIndex != 0) {
      return const Center(child: Text('Coming soon'));
    }
    return Column(
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.md),
        const ProgressCard(
          calories: 1284,
          fatPct: 0.29,
          proPct: 0.65,
          carbPct: 0.85,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSearchField(),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: _buildList(recipesAsync)),
      ],
    );
  }

  /// Search box; onChanged only forwards to the notifier, which debounces
  /// (300 ms) and cancels the previous request (deck p. 63/117).
  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search recipes…',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _onSearchChanged(''),
              ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    ref.read(recipesProvider.notifier).search(value);
  }

  /// UI = f(State): each AsyncValue branch declares what the list looks like
  /// in that state (deck p. 9, p. 99–101). Cache-served data gets the offline
  /// banner (deck p. 110–111).
  Widget _buildList(AsyncValue<RecipesResult> recipesAsync) {
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
              onPressed: () => ref.read(recipesProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (result) {
        final list = result.recipes.isEmpty
            ? Center(
                child: Text(
                  'No recipes found. Try another search.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                // Android-style clamp: no rubber-band overscroll at the list ends.
                physics: const ClampingScrollPhysics(),
                itemCount: result.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = result.recipes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: RecipeCard(
                      recipe: recipe,
                      onTap: () => _openDetails(recipe),
                    ),
                  );
                },
              );
        return Column(
          children: [
            if (result.fromCache) ...[
              const _OfflineBanner(),
              const SizedBox(height: AppSpacing.sm),
            ],
            Expanded(child: list),
          ],
        );
      },
    );
  }

  void _openDetails(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe)),
    );
  }

  Widget _buildNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedTabIndex,
      onTap: (index) => setState(() => _selectedTabIndex = index),
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.wb_sunny_outlined),
          label: 'Today',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Meal Plan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket_outlined),
          label: 'Grocery List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
      ],
    );
  }
}

/// Shown above the list when the data came from the local cache because the
/// network is unavailable (deck p. 110–111: cached data + offline indicator).
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.25),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "You're offline — only saved recipes are shown",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar (left) + menu icon (right), pushed to the edges.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.bubble,
          child: Icon(Icons.person, color: AppColors.textSecondary),
        ),
        Icon(Icons.menu, color: AppColors.textPrimary),
      ],
    );
  }
}
