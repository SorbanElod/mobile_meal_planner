import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/overlay_icon_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../models/recipe.dart';

/// Recipe Details: hero image with back + favorite buttons, bottom sheet with
/// title, nutrition stats, scalable ingredients, instructions and the Start
/// cooking button. Works for any recipe — the (API-loaded) record arrives via
/// the constructor, so the screen stays parameterized and stateless re data.
/// The heart reflects the shared favorites state, same as on Home.
class RecipeDetailsScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends ConsumerState<RecipeDetailsScreen> {
  int _serves = 2; // ephemeral state: only this screen's stepper changes it

  Recipe get _recipe => widget.recipe;

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(
      favoritesProvider.select((fav) => fav.value?.contains(_recipe.id) ?? false),
    );
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.42,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildHeroImage(_recipe.imageUrl),
                // SafeArea keeps the controls below the status bar; the
                // image itself stays edge-to-edge underneath.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OverlayIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FavoriteButton(
                                isFavorite: isFavorite,
                                onTap: () => ref
                                    .read(favoritesProvider.notifier)
                                    .toggle(_recipe.id),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              OverlayIconButton(
                                icon: Icons.more_horiz,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // Pull the sheet up over the hero's bottom edge (rounded top corners).
            child: Transform.translate(
              offset: const Offset(0, -AppSpacing.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lg.copyWith(
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleRow(recipe: _recipe),
                    const SizedBox(height: AppSpacing.md),
                    _NutritionRow(recipe: _recipe),
                    const SizedBox(height: AppSpacing.lg),
                    _IngredientsHeader(
                      serves: _serves,
                      onServesChanged: (v) => setState(() => _serves = v),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(child: _buildIngredientsAndInstructions()),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(label: 'Start cooking', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ingredients (scaled by the serves stepper) followed by the instructions
  /// block — all from the API record. Falls back to a message when the API
  /// record has neither (null-safety, deck p. 76–78).
  Widget _buildIngredientsAndInstructions() {
    final hasInstructions = _recipe.instructions != null;
    final itemCount = _recipe.ingredients.length + (hasInstructions ? 1 : 0);
    if (itemCount == 0) {
      return Center(
        child: Text(
          'No details available for this recipe.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _recipe.ingredients.length) {
          final ingredient = _recipe.ingredients[index];
          return _IngredientRow(
            name: ingredient.name,
            amount: ingredient.amountFor(_serves),
          );
        }
        return _InstructionsBlock(text: _recipe.instructions!);
      },
    );
  }

  /// Network URL from the API or a bundled asset; missing/failed → placeholder.
  static Widget _buildHeroImage(String? imageUrl) {
    final provider = _imageProvider(imageUrl);
    if (provider == null) return _placeholder();
    return Image(
      image: provider,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  static ImageProvider? _imageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    return imageUrl.startsWith('assets/')
        ? AssetImage(imageUrl)
        : NetworkImage(imageUrl);
  }

  static Widget _placeholder() => Container(
    color: AppColors.bubble,
    child: const Icon(Icons.restaurant_menu, color: AppColors.textSecondary),
  );
}

class _TitleRow extends StatelessWidget {
  final Recipe recipe;
  const _TitleRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        const Icon(Icons.refresh, color: AppColors.textPrimary),
        Expanded(
          child: Column(
            children: [
              Text(
                recipe.title,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                recipe.subtitle,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final Recipe recipe;
  const _NutritionRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TheMealDB has no nutrition data → show "N/A", never a fake 0 (deck p. 78).
        _NutritionStat(value: _stat(recipe.energyKcal, 'k'), label: 'Energy'),
        _NutritionStat(value: _stat(recipe.proteinG, 'g'), label: 'Protein'),
        _NutritionStat(value: _stat(recipe.carbsG, 'g'), label: 'Carbs'),
        _NutritionStat(value: _stat(recipe.fatG, 'g'), label: 'Fat'),
      ],
    );
  }

  static String _stat(int? value, String unit) =>
      value != null ? '$value $unit' : 'N/A';
}

class _NutritionStat extends StatelessWidget {
  final String value;
  final String label;
  const _NutritionStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _IngredientsHeader extends StatelessWidget {
  final int serves;
  final ValueChanged<int> onServesChanged;
  const _IngredientsHeader({
    required this.serves,
    required this.onServesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Expanded + ellipsis so the header never overflows narrow screens.
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Ingredients',
              style: textTheme.titleMedium,
              children: [
                TextSpan(text: '  $serves serves', style: textTheme.bodySmall),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.sm,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: serves > 1
                    ? () => onServesChanged(serves - 1)
                    : null,
              ),
              Text('$serves', style: textTheme.bodyMedium),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => onServesChanged(serves + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionsBlock extends StatelessWidget {
  final String text;
  const _InstructionsBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instructions', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String name;
  final String amount;
  const _IngredientRow({required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: textTheme.bodyMedium),
          Text(amount, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
