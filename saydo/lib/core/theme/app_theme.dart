import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the SayDo [ThemeData] for the given [brightness].
ThemeData buildSayDoTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onBackground,
    secondary: AppColors.primaryLight,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: isDark ? AppColors.surface : Colors.white,
    onSurface: isDark ? AppColors.onSurface : const Color(0xFF1A1A2E),
    surfaceContainerHighest: isDark ? AppColors.surfaceVariant : const Color(0xFFF0F0F5),
    onSurfaceVariant: isDark ? AppColors.onSurfaceVariant : const Color(0xFF555577),
    outline: isDark ? AppColors.outline : const Color(0xFFCCCCDD),
    outlineVariant: isDark ? AppColors.outlineVariant : const Color(0xFFE0E0EE),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark ? AppColors.background : Colors.white,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: isDark ? AppColors.background : Colors.white,
      foregroundColor: isDark ? AppColors.onBackground : const Color(0xFF1A1A2E),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: isDark ? AppColors.surface : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.outline : const Color(0xFFE0E0EE),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.surfaceVariant : const Color(0xFFF5F5FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.outline : const Color(0xFFCCCCDD),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.outline : const Color(0xFFCCCCDD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.outlineVariant : const Color(0xFFE0E0EE),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? AppColors.surfaceVariant : const Color(0xFF2A2A3E),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
