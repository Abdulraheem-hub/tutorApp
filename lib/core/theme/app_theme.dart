/**
 * @context7:feature:theme
 * @context7:dependencies:material_color_utilities,flutter
 * @context7:pattern:material_design_3
 * 
 * Material Design 3 theme configuration for TutorPay app
 * Provides light and dark theme with custom color scheme
 */

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class AppTheme {
  // Primary brand color - Purple used in the dashboard design (exact match from image)
  static const Color _primarySeedColor = Color(0xFF6366F1); // Indigo/Purple
  
  // Exact colors from the TutorPay dashboard image
  static const Color backgroundColor = Color(0xFFF8F9FA); // Very light grey background
  static const Color cardBackground = Colors.white;
  static const Color primaryPurple = Color(0xFF6366F1); // Purple for buttons
  static const Color lightPurple = Color(0xFFEEF2FF); // Light purple background
  static const Color greenPositive = Color(0xFF10B981); // Green for positive values
  static const Color orangePending = Color(0xFFE97B47); // Orange for pending
  static const Color purpleGoal = Color(0xFF8B5CF6); // Purple for monthly goal
  static const Color textDark = Color(0xFF1F2937); // Dark text
  static const Color textLight = Color(0xFF6B7280); // Light grey text
  
  // Custom color scheme based on Material Design 3
  static ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeedColor,
    brightness: Brightness.light,
  );
  
  static ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeedColor,
    brightness: Brightness.dark,
  );

  // Custom colors for dashboard components (exact match from image)
  static const Color successColor = Color(0xFF10B981); // Green for positive values
  static const Color warningColor = Color(0xFFE97B47); // Orange for pending  
  static const Color errorColor = Color(0xFFEF4444); // Red for overdue
  static const Color infoColor = Color(0xFF6366F1); // Purple for info
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme.copyWith(
        surface: backgroundColor, // Light grey background like in image
        onSurface: textDark, // Dark text
        primary: primaryPurple, // Purple buttons
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightColorScheme.surface,
        foregroundColor: _lightColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _lightColorScheme.onSurface,
        ),
      ),
      
      // Card Theme (pure white like in image)
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardBackground,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: _lightColorScheme.surface,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightColorScheme.surface,
        selectedItemColor: _lightColorScheme.primary,
        unselectedItemColor: _lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkColorScheme.surface,
        foregroundColor: _darkColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _darkColorScheme.onSurface,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _darkColorScheme.surface,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: _darkColorScheme.surface,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkColorScheme.surface,
        selectedItemColor: _darkColorScheme.primary,
        unselectedItemColor: _darkColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

// Extension for custom colors
extension CustomColors on ColorScheme {
  Color get success => AppTheme.successColor;
  Color get warning => AppTheme.warningColor;
  Color get info => AppTheme.infoColor;
}
