import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// The one overlay button used on hero images (back, favorite, more):
/// a fixed-size circular chip, so every control is identical in size and
/// background and stays readable on any photo.
class OverlayIconButton extends StatelessWidget {
  static const double _boxSize = 40;

  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const OverlayIconButton({
    super.key,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _boxSize,
        height: _boxSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
