import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/favorite_button.dart';
import '../models/recipe.dart';

/// One reusable, data-driven recipe card: photo + favorite overlay.
/// Works with any [Recipe], is screen-independent, and reports taps
/// upward via [onTap] (wired to navigation in MP-05).
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: AppRadius.md,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(recipe.imageUrl),
            ),
          ),
          const Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: FavoriteButton(),
          ),
        ],
      ),
    );
  }

  /// Network URLs from the API, bundled assets for local data; a missing
  /// image (null/empty, deck p. 76) or a failed load both get a placeholder.
  static Widget _buildImage(String? imageUrl) {
    final provider = _imageProvider(imageUrl);
    if (provider == null) return _placeholder();
    return Image(
      image: provider,
      width: double.infinity,
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
    width: double.infinity,
    color: AppColors.bubble,
    child: const Icon(Icons.restaurant_menu, color: AppColors.textSecondary),
  );
}
