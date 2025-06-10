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
    final primaryColor =
        constants.availableColors.isNotEmpty
            ? constants.availableColors[0]
            : Colors.deepPurpleAccent;

    var baseColorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light, // Domyślnie jasny motyw
    );

    final customColorScheme = baseColorScheme.copyWith(
      primary: primaryColor[600]!, // Jasny motyw
      primaryContainer: primaryColor[200]!,
      secondary: primaryColor[400]!,
    );

    return ThemeData.from(colorScheme: customColorScheme, useMaterial3: true);
  }

  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getInt('color_palette_version') ?? 0;
      if (savedVersion < constants.colorPaletteVesion) {
        // Resetuj kolory jeśli wersja się zmieniła
        await prefs.remove('primary_color');
        await prefs.setInt(
          'color_palette_version',
          constants.colorPaletteVesion,
        );
      }

      // Załaduj motyw
      final themeModeString = prefs.getString('theme_mode') ?? 'system';
      final isDark =
          themeModeString == 'dark' ||
          (themeModeString == 'system' &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);

      // Załaduj kolor
      final colorIndex = prefs.getInt('primary_color') ?? 0;
      final availableColors = constants.availableColors;

      final primaryColor =
          colorIndex < availableColors.length
              ? availableColors[colorIndex]
              : constants
                  .availableColors[0]; // Użyj pierwszego z listy zamiast Colors.deepPurpleAccent

      // UŻYJ TEJ SAMEJ LOGIKI CO W updateTheme()
      var baseColorScheme = ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      );

      // Zastosuj te same modyfikacje co w updateTheme()
      final customColorScheme = baseColorScheme.copyWith(
        primary: primaryColor[isDark ? 400 : 600]!,
        primaryContainer: primaryColor[isDark ? 800 : 200]!,
        secondary: primaryColor[isDark ? 200 : 400]!,
      );

      // Zaktualizuj motyw z niestandardowym ColorScheme
      value = ThemeData.from(
        colorScheme: customColorScheme,
        useMaterial3: true,
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

      var baseColorScheme = ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      );

      // Zmodyfikuj tylko wybrane kolory
      //TODO mozna pozmieniac te kolorki
      final customColorScheme = baseColorScheme.copyWith(
        primary: primaryColor[isDark ? 400 : 600]!,
        primaryContainer: primaryColor[isDark ? 800 : 200]!,
        secondary: primaryColor[isDark ? 200 : 400]!,
        // Pozostałe kolory zostają z fromSeed()
      );

      value = ThemeData.from(
        colorScheme: customColorScheme,
        useMaterial3: true,
      );

      // value = ThemeData.from(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: primaryColor,
      //     brightness: isDark ? Brightness.dark : Brightness.light,
      //   ),
      // );

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
