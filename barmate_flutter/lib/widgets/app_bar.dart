import 'package:barmate/data/notifiers.dart';
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

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
                children: hour < 12
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
              const Text(
                'User Name',
                style: TextStyle(
                  fontSize: fontSize1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
              child: IconButton(
              icon: Icon(
                currentTheme ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
                onPressed: () {
                  themeNotifier.value = !themeNotifier.value;
                },
              ),
            ),
            
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}