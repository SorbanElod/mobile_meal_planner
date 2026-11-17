import 'package:material_ui/material_ui.dart';

import '../theme/app_spacing.dart';

/// The one button style used across the app (styled via
/// [AppTheme]'s elevatedButtonTheme: primary bg, md radius).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
