import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Border-radius tokens.
abstract final class AppRadius {
  static const sm = BorderRadius.all(Radius.circular(8)); // stepper box
  static const md = BorderRadius.all(Radius.circular(16)); // cards, buttons
  static const lg = BorderRadius.all(Radius.circular(24)); // bottom sheet top
  static final full = BorderRadius.circular(999); // avatars, rings
}

/// App-wide [ThemeData] + [TextTheme] built from the tokens.
/// Typography roles: headlineMedium = Page Title, titleMedium = Section Title,
/// bodyMedium = Body, bodySmall/labelSmall = Caption.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final textTheme = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ), // Page Title
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ), // Section Title
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ), // Body
      bodySmall: base.textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
      ), // Caption
      labelSmall: base.textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
      ), // Caption
    );

    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
