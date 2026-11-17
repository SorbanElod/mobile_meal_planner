import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// "Today's Progress" card: calories + three macro rings + motivational
/// bubble. Data comes in via the constructor, so it is reusable as-is.
class ProgressCard extends StatelessWidget {
  final int calories;
  final double fatPct;
  final double proPct;
  final double carbPct;

  const ProgressCard({
    super.key,
    required this.calories,
    required this.fatPct,
    required this.proPct,
    required this.carbPct,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Today's Progress",
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View more',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              // Ring size adapts to the available width so the % label always
              // fits inside the ring (44 px at 360 px wide, up to 64 px).
              final ringSize = ((constraints.maxWidth - 140) / 3).clamp(
                44.0,
                64.0,
              );
              return Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calories', style: textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: AppColors.accentAmber,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(_caloriesLabel, style: textTheme.titleLarge),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MacroRing(
                          pct: fatPct,
                          label: 'Fat',
                          color: AppColors.accentAmber,
                          size: ringSize,
                        ),
                        MacroRing(
                          pct: proPct,
                          label: 'Pro',
                          color: AppColors.accentBlue,
                          size: ringSize,
                        ),
                        MacroRing(
                          pct: carbPct,
                          label: 'Carb',
                          color: AppColors.primary,
                          size: ringSize,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.bubble,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.bubble,
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    "Keep the pace! You're doing great.",
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "1284" -> "1,284" without pulling in a formatting package.
  String get _caloriesLabel => calories.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

/// Circular percentage indicator with centered value + label.
class MacroRing extends StatelessWidget {
  final double pct;
  final String label;
  final Color color;
  final double size;

  const MacroRing({
    super.key,
    required this.pct,
    required this.label,
    required this.color,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: pct,
              color: color,
              backgroundColor: AppColors.border,
              strokeWidth: size / 8,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(pct * 100).round()}%',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(label, style: textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
