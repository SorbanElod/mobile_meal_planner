import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_meal_planner/main.dart';

void main() {
  testWidgets('App builds and renders the home placeholder', (tester) async {
    await tester.pumpWidget(const MealPlannerApp());
    expect(find.text('Meal Planner'), findsOneWidget);
  });
}
