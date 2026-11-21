import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../favorites/presentation/favorites_screen.dart';
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
  // Ephemeral state: only this widget's bottom nav uses it (deck p. 10).
  int _selectedTabIndex = 0;

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
  Widget _buildBody(AsyncValue<List<Recipe>> recipesAsync) {
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
        Expanded(child: _buildList(recipesAsync)),
      ],
    );
  }

  /// UI = f(State): each AsyncValue branch declares what the list looks like
  /// in that state (deck p. 9, p. 99–101).
  Widget _buildList(AsyncValue<List<Recipe>> recipesAsync) {
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
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Text(
              'No recipes found. Try another search.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          // Android-style clamp: no rubber-band overscroll at the list ends.
          physics: const ClampingScrollPhysics(),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RecipeCard(
                recipe: recipe,
                onTap: () => _openDetails(recipe),
              ),
            );
          },
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
