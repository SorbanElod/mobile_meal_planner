import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../models/recipe.dart';

/// One reusable, data-driven recipe card: photo + shared favorite overlay.
/// Works with any [Recipe], is screen-independent; card taps go up via
/// [onTap] (navigation), heart taps toggle the shared favorites provider.
class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select() rebuilds the heart only when THIS recipe's favorite state flips.
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (fav) => fav.value?.contains(recipe.id) ?? false,
      ),
    );
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
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: FavoriteButton(
              isFavorite: isFavorite,
              onTap: () =>
                  ref.read(favoritesProvider.notifier).toggle(recipe.id),
            ),
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
