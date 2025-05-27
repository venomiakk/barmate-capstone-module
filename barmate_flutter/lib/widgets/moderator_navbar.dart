import 'package:flutter/material.dart';
import 'package:barmate/data/notifiers.dart';

class ModeratorNavbar extends StatelessWidget {
  const ModeratorNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (value) => selectedPageNotifier.value = value,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Collections',
            ),
           
          ],
        );
      },
    );
  }
}
