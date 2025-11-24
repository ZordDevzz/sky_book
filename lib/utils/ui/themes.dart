import 'package:flutter/material.dart';

// Caffeine color scheme
const _lightPrimary = Color(0xFF644a40);
const _lightSecondary = Color(0xFFffdfb5);
const _lightBackground = Color(0xFFf9f9f9);
const _lightCardBackground = Color(0xFFf9f9f9);
const _lightMutedForeground = Color(0xFF646464);
const _lightBorder = Color(0xFFd8d8d8);
const _lightSurface = Color(0xFF202020);
const _lightSecondaryForeground = Color(0xFF582d1d);

const _darkPrimary = Color(0xFFffe0c2);
const _darkSecondary = Color(0xFF393028);
const _darkBackground = Color(0xFF111111);
const _darkCardBackground = Color(0xFF191919);
const _darkMutedForeground = Color(0xFFb4b4b4);
const _darkBorder = Color(0xFF201e18);
const _darkSurface = Color(0xFFeeeeee);
const _darkSecondaryForeground = Color(0xFFffe0c2);

final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  seedColor: _lightPrimary,
  brightness: Brightness.light,
  primary: _lightPrimary,
  secondary: _lightSecondary,
  surface: _lightBackground,
  onSurface: _lightSurface,
  onSecondary: _lightSecondaryForeground,
  outline: _lightBorder,
);

final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: _darkPrimary,
  brightness: Brightness.dark,
  primary: _darkPrimary,
  secondary: _darkSecondary,
  surface: _darkBackground,
  onSurface: _darkSurface,
  onSecondary: _darkSecondaryForeground,
  outline: _darkBorder,
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  scaffoldBackgroundColor: _lightColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.surface,
    foregroundColor: _lightColorScheme.onSurface,
    elevation: 0,
    centerTitle: true,
  ),
  cardColor: _lightColorScheme.surface,
  dividerColor: _lightColorScheme.outlineVariant,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: _inputDecoration(_lightColorScheme),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _lightColorScheme.surface,
    selectedItemColor: _lightColorScheme.primary,
    unselectedItemColor: _lightMutedForeground,
    type: BottomNavigationBarType.shifting,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _lightColorScheme.secondary,
    foregroundColor: _lightColorScheme.onSecondary,
  ),
  dialogTheme: DialogThemeData(backgroundColor: _lightCardBackground),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  scaffoldBackgroundColor: _darkColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _darkColorScheme.surface,
    foregroundColor: _darkColorScheme.onSurface,
    elevation: 0,
    centerTitle: true,
  ),
  cardColor: _darkColorScheme.surface,
  dividerColor: _darkColorScheme.outlineVariant,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: _inputDecoration(_darkColorScheme),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _darkColorScheme.surface,
    selectedItemColor: _darkColorScheme.primary,
    unselectedItemColor: _darkMutedForeground,
    type: BottomNavigationBarType.shifting,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _darkColorScheme.secondary,
    foregroundColor: _darkColorScheme.onSecondary,
  ),
  dialogTheme: DialogThemeData(backgroundColor: _darkCardBackground),
);

InputDecorationTheme _inputDecoration(ColorScheme colorScheme) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: colorScheme.outline, width: 1),
  );

  return InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.surface,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    ),
    labelStyle: TextStyle(color: colorScheme.onSurface),
    hintStyle: TextStyle(color: colorScheme.onSurface),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
