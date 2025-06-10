import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/controllers/notifications_controller.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:barmate/screens/user_screens/notifications_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final authService = AuthService();
  String username = ''; // Domyślna wartość
  bool _isLoading = true;
  var logger = Logger(printer: PrettyPrinter());

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await UserPreferences.getInstance();
      setState(() {
        username = prefs.getUserName();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading username: $e');
      setState(() {
        username = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int hour = now.hour;
    const double fontSize1 = 22;
    const double fontSize2 = 18;

    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return AppBar(
          elevation: 0,
          toolbarHeight: 100,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children:
                    hour < 12
                        ? [
                          const Icon(Icons.wb_sunny, size: 30),
                          const SizedBox(width: 10),
                          const Text(
                            'Good Morning',
                            style: TextStyle(fontSize: fontSize2),
                          ),
                        ]
                        : hour < 18
                        ? [
                          const Icon(Icons.wb_sunny, size: 30),
                          const SizedBox(width: 10),
                          const Text(
                            'Good Afternoon',
                            style: TextStyle(fontSize: fontSize2),
                          ),
                        ]
                        : [
                          const Icon(Icons.nights_stay, size: 30),
                          const SizedBox(width: 10),
                          const Text(
                            'Good Evening',
                            style: TextStyle(fontSize: fontSize2),
                          ),
                        ],
              ),
              _isLoading
                  ? const Text(
                    "Loading...",
                    style: TextStyle(fontSize: fontSize2),
                  )
                  : Text(
                    username,
                    style: const TextStyle(
                      fontSize: fontSize1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ],
          ),
          actions: [
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
    child: Consumer<NotificationService>(
      builder: (context, notifier, child) {
        final hasUnread = notifier.hasUnread;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );

                Provider.of<NotificationService>(context, listen: false).markAllAsRead();
              },

            ),
            if (hasUnread)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    ),
  ),
],

        );
      },
    );
  }
}
