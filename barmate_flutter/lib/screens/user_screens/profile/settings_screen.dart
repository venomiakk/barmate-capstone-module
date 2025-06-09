import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:barmate/data/notifiers.dart'; // Dodaj ten import
import 'package:barmate/constants.dart' as constants;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var logger = Logger(printer: PrettyPrinter());

  ThemeMode _themeMode = ThemeMode.system;
  MaterialColor _primaryColor = constants.availableColors[0];

  final List<MaterialColor> _availableColors = constants.availableColors;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Załaduj motyw
      final themeModeString = prefs.getString('theme_mode') ?? 'system';
      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      // Załaduj kolor
      final colorIndex = prefs.getInt('primary_color') ?? 0;
      if (colorIndex < _availableColors.length) {
        _primaryColor = _availableColors[colorIndex];
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      logger.e("Error loading settings: $e");
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        default:
          modeString = 'system';
      }

      await prefs.setString('theme_mode', modeString);
      setState(() {
        _themeMode = mode;
      });

      // Powiadom aplikację o zmianie motywu
      _notifyThemeChange();
    } catch (e) {
      logger.e("Error saving theme mode: $e");
    }
  }

  Future<void> _savePrimaryColor(MaterialColor color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorIndex = _availableColors.indexOf(color);

      await prefs.setInt('primary_color', colorIndex);
      setState(() {
        _primaryColor = color;
      });

      // Powiadom aplikację o zmianie koloru
      _notifyThemeChange();
    } catch (e) {
      logger.e("Error saving primary color: $e");
    }
  }

  void _notifyThemeChange() {
    // Zaktualizuj globalny notifier
    appThemeNotifier.updateTheme(_themeMode, _primaryColor);
    logger.d("Theme changed: $_themeMode, Color: $_primaryColor");
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }

  String _getColorDisplayName(MaterialColor color) {
    switch (color.value) {
      case 0xFF1976D2:
        return 'Electric Blue';
      case 0xFF388E3C:
        return 'Forest Green';
      case 0xFF7B1FA2:
        return 'Royal Purple';
      case 0xFFFF5722:
        return 'Vibrant Orange';
      case 0xFFD32F2F:
        return 'Crimson Red';
      case 0xFF00796B:
        return 'Ocean Teal';
      case 0xFF303F9F:
        return 'Deep Indigo';
      case 0xFFE91E63:
        return 'Hot Pink';
      default:
        return 'Custom Color';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Theme mode selector
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...ThemeMode.values.map(
                    (mode) => RadioListTile<ThemeMode>(
                      title: Text(_getThemeDisplayName(mode)),
                      value: mode,
                      groupValue: _themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          _saveThemeMode(value);
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Color section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.color_lens,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Primary Color',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Choose your preferred color theme',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Color grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _availableColors.length,
                    itemBuilder: (context, index) {
                      final color = _availableColors[index];
                      final isSelected = color == _primaryColor;

                      return GestureDetector(
                        onTap: () => _savePrimaryColor(color),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                isSelected
                                    ? Border.all(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      width: 3,
                                    )
                                    : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                  : null,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Selected: ${_getColorDisplayName(_primaryColor)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional settings section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Other Settings',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Placeholder for other settings
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification preferences'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      // TODO: Navigate to notification settings
                      logger.d("Navigate to notification settings");
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('User Preferences'),
                    subtitle: const Text('Customize your experience'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      // TODO: Navigate to language settings
                      logger.d("Navigate to user preferences");
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
