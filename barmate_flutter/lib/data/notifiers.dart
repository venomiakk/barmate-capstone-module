import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barmate/constants.dart' as constants;

// Theme Notifier dla motywu (jasny/ciemny)
final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

// Theme Data Notifier dla całego motywu (kolor + jasny/ciemny)
class AppThemeNotifier extends ValueNotifier<ThemeData> {
  AppThemeNotifier() : super(_getInitialTheme()) {
    _loadThemeFromPreferences();
  }

  static ThemeData _getInitialTheme() {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
  }

  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Załaduj motyw
      final themeModeString = prefs.getString('theme_mode') ?? 'system';
      final isDark =
          themeModeString == 'dark' ||
          (themeModeString == 'system' &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);

      // Załaduj kolor
      final colorIndex = prefs.getInt('primary_color') ?? 0;
      final availableColors = [
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.red,
        Colors.teal,
        Colors.indigo,
        Colors.pink,
      ];

      final primaryColor =
          colorIndex < availableColors.length
              ? availableColors[colorIndex]
              : Colors.blue;

      // Zaktualizuj motyw
      value = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );

      // Zaktualizuj stary notifier też
      themeNotifier.value = isDark;
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> updateTheme(ThemeMode mode, MaterialColor primaryColor) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Zapisz ustawienia
      String modeString;
      bool isDark;

      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          isDark = false;
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          isDark = true;
          break;
        default:
          modeString = 'system';
          isDark =
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      }

      await prefs.setString('theme_mode', modeString);

      final availableColors = constants.availableColors;

      final colorIndex = availableColors.indexOf(primaryColor);
      await prefs.setInt('primary_color', colorIndex);

      // Zaktualizuj motyw
      value = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );

      // Zaktualizuj stary notifier też
      themeNotifier.value = isDark;
    } catch (e) {
      print('Error updating theme: $e');
    }
  }
}

final AppThemeNotifier appThemeNotifier = AppThemeNotifier();

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);

void resetNotifiersToDefaults() {
  selectedPageNotifier.value = 0;
  themeNotifier.value = true;
}
