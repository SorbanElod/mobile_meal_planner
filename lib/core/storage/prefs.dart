import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app-wide SharedPreferencesAsync instance, provided via Riverpod so it
/// is injectable and overridable in tests. Lives in core because multiple
/// features (favorites, recipe cache) use it.
final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (_) => SharedPreferencesAsync(),
);
