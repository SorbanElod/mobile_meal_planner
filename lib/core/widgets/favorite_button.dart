import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Heart toggle on a recipe card. Now a pure, data-driven widget: the shared
/// favorite state lives in `favoritesProvider` (Riverpod), so [isFavorite]
/// comes in via the constructor and taps go up via [onTap] — data down,
/// callbacks up. No local state anymore.
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const FavoriteButton({super.key, required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
