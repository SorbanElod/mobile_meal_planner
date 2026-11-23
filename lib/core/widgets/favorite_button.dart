import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'overlay_icon_button.dart';

/// Heart toggle on a recipe card / details hero. A pure, data-driven widget:
/// the shared favorite state lives in `favoritesProvider` (Riverpod), so
/// [isFavorite] comes in via the constructor and taps go up via [onTap] —
/// data down, callbacks up. Rendered as the shared [OverlayIconButton], so it
/// is exactly the same size as the other hero controls.
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const FavoriteButton({super.key, required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OverlayIconButton(
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      iconColor: isFavorite ? AppColors.primary : AppColors.textSecondary,
      onTap: onTap,
    );
  }
}
