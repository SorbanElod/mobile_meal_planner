import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/recipe.dart';

/// Recipe Details: hero image with back button, bottom sheet with title,
/// nutrition stats, scalable ingredients and the Start cooking button.
/// Works for any recipe — data arrives via the constructor.
class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  int _serves = 2; // local UI state: only this screen's stepper changes it

  Recipe get _recipe => widget.recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.42,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: _imageProvider(_recipe.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.bubble,
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {},
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
                    Expanded(
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: _recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = _recipe.ingredients[index];
                          return _IngredientRow(
                            name: ingredient.name,
                            amount: ingredient.amountFor(_serves),
                          );
                        },
                      ),
                    ),
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

  static ImageProvider _imageProvider(String imageUrl) {
    return imageUrl.startsWith('assets/')
        ? AssetImage(imageUrl)
        : NetworkImage(imageUrl);
  }
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
        _NutritionStat(value: '${recipe.energyKcal} k', label: 'Energy'),
        _NutritionStat(value: '${recipe.proteinG} g', label: 'Protein'),
        _NutritionStat(value: '${recipe.carbsG} g', label: 'Carbs'),
        _NutritionStat(value: '${recipe.fatG} g', label: 'Fat'),
      ],
    );
  }
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
        Text.rich(
          TextSpan(
            text: 'Ingredients',
            style: textTheme.titleMedium,
            children: [
              TextSpan(text: '  $serves serves', style: textTheme.bodySmall),
            ],
          ),
        ),
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
