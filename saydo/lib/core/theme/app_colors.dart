import 'package:flutter/material.dart';

/// SayDo color palette — dark navy / purple-blue gradient theme.
class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF0A0A1A);
  static const Color surface = Color(0xFF12122B);
  static const Color surfaceVariant = Color(0xFF1A1A3D);

  // Gradient (top of screens)
  static const Color gradientStart = Color(0xFF2D1B69);
  static const Color gradientEnd = Color(0xFF0A0A1A);

  // Primary accent
  static const Color primary = Color(0xFF5B5BD6);
  static const Color primaryLight = Color(0xFF7B7BF0);
  static const Color primaryContainer = Color(0xFF2A2A5E);

  // Text
  static const Color onBackground = Color(0xFFE8E8F0);
  static const Color onSurface = Color(0xFFC8C8DC);
  static const Color onSurfaceVariant = Color(0xFF8888AA);

  // Semantic
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFB74D);

  // Outline / dividers
  static const Color outline = Color(0xFF2A2A4A);
  static const Color outlineVariant = Color(0xFF1E1E3A);
}
