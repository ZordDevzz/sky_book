import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(colorScheme: _customLightScheme(), radius: 0.7);
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(colorScheme: _customDarkScheme(), radius: 0.7);
  }

  static ColorScheme _customLightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      background: Color(0xfff9f9f9),
      foreground: Color(0xff202020),
      card: Color(0xfffcfcfc),
      cardForeground: Color(0xff202020),
      popover: Color(0xfffcfcfc),
      popoverForeground: Color(0xff202020),
      primary: Color(0xff644a40),
      primaryForeground: Color(0xffffffff),
      secondary: Color(0xffffdfb5),
      secondaryForeground: Color(0xff582d1d),
      muted: Color(0xffefefef),
      mutedForeground: Color(0xff646464),
      accent: Color(0xffe8e8e8),
      accentForeground: Color(0xff202020),
      destructive: Color(0xffe54d2e),
      destructiveForeground: Color(0xffffffff),
      border: Color(0xffd8d8d8),
      input: Color(0xffd8d8d8),
      ring: Color(0xff644a40),
      chart1: Color(0xff644a40),
      chart2: Color(0xffffdfb5),
      chart3: Color(0xffe8e8e8),
      chart4: Color(0xffffe6c4),
      chart5: Color(0xff66493e),
      sidebar: Color(0xfffbfbfb),
      sidebarForeground: Color(0xff252525),
      sidebarPrimary: Color(0xff343434),
      sidebarPrimaryForeground: Color(0xfffbfbfb),
      sidebarAccent: Color(0xfff7f7f7),
      sidebarAccentForeground: Color(0xff343434),
      sidebarBorder: Color(0xffebebeb),
      sidebarRing: Color(0xffb5b5b5),
    );
  }

  static ColorScheme _customDarkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xff111111),
      foreground: Color(0xffeeeeee),
      card: Color(0xff191919),
      cardForeground: Color(0xffeeeeee),
      popover: Color(0xff191919),
      popoverForeground: Color(0xffeeeeee),
      primary: Color(0xffffe0c2),
      primaryForeground: Color(0xff081a1b),
      secondary: Color(0xff393028),
      secondaryForeground: Color(0xffffe0c2),
      muted: Color(0xff222222),
      mutedForeground: Color(0xffb4b4b4),
      accent: Color(0xff2a2a2a),
      accentForeground: Color(0xffeeeeee),
      destructive: Color(0xffe54d2e),
      destructiveForeground: Color(0xffffffff),
      border: Color(0xff201e18),
      input: Color(0xff484848),
      ring: Color(0xffffe0c2),
      chart1: Color(0xffffe0c2),
      chart2: Color(0xff393028),
      chart3: Color(0xff2a2a2a),
      chart4: Color(0xff42382e),
      chart5: Color(0xffffe0c1),
      sidebar: Color(0xff18181b),
      sidebarForeground: Color(0xfff4f4f5),
      sidebarPrimary: Color(0xff1d4ed8),
      sidebarPrimaryForeground: Color(0xffffffff),
      sidebarAccent: Color(0xff27272a),
      sidebarAccentForeground: Color(0xfff4f4f5),
      sidebarBorder: Color(0xff27272a),
      sidebarRing: Color(0xffd4d4d8),
    );
  }
}
