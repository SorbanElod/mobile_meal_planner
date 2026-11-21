import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  // Riverpod owns the object graph now: ProviderScope at the root, screens
  // read their state via ref.watch (no manual composition root anymore).
  runApp(const ProviderScope(child: MealPlannerApp()));
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const _ClampScrollBehavior(),
      home: const HomeScreen(),
    );
  }
}

/// Forces clamping (Android-style) overscroll physics on every scrollable,
/// so no list rubber-bands at its ends.
class _ClampScrollBehavior extends MaterialScrollBehavior {
  const _ClampScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
