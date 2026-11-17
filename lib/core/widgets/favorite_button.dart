import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Heart toggle on a recipe card. Owns only its local `isFavorite` state,
/// so `setState()` is correct here; reports changes upward via [onToggled].
class FavoriteButton extends StatefulWidget {
  final ValueChanged<bool>? onToggled;

  const FavoriteButton({super.key, this.onToggled});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  void _toggle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onToggled?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
