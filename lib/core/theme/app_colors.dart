import 'package:material_ui/material_ui.dart';

/// Color tokens — roles, not looks.
/// Values eyeballed from the Figma exports (docs/figma-export/);
/// confirm against the Figma styles panel before finalizing.
abstract final class AppColors {
  static const primary = Color(0xFF7C5CFC); // buttons, Carb ring, primary actions
  static const accentBlue = Color(0xFF2F80ED); // links, Pro ring
  static const accentAmber = Color(0xFFF2C94C); // Fat ring
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF); // cards, bottom sheet
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF9CA3AF);
  static const bubble = Color(0xFFF3F4F6); // motivational bubble
  static const onPrimary = Color(0xFFFFFFFF); // text/icons on primary
}
