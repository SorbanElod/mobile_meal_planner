import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../recipes/models/recipe.dart';
import '../../recipes/presentation/recipe_card.dart';
import '../../recipes/presentation/recipe_details_screen.dart';
import 'home_view_model.dart';
import 'widgets/progress_card.dart';

/// Home screen: header, progress card, scrollable recipe list, bottom nav.
/// Renders [HomeViewModel] state and forwards actions to it — it never
/// talks to the data layer directly.
class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
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
                Expanded(child: _buildList(context)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildNav(),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    switch (viewModel.status) {
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case HomeStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.errorMessage ?? 'Something went wrong',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: viewModel.loadRecipes,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case HomeStatus.empty:
        return Center(
          child: Text(
            'No recipes match your preferences yet',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
      case HomeStatus.success:
        return ListView.builder(
          // Android-style clamp: no rubber-band overscroll at the list ends.
          physics: const ClampingScrollPhysics(),
          itemCount: viewModel.recipes.length,
          itemBuilder: (context, index) {
            final recipe = viewModel.recipes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RecipeCard(
                recipe: recipe,
                onTap: () => _openDetails(context, recipe),
              ),
            );
          },
        );
    }
  }

  void _openDetails(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe)),
    );
  }

  Widget _buildNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: viewModel.selectedTabIndex,
      onTap: viewModel.selectTab,
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
