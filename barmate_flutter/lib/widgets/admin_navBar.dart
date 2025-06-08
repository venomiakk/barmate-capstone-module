import 'package:flutter/material.dart';
import 'package:barmate/data/notifiers.dart';

class AdminNavbar extends StatelessWidget {
  const AdminNavbar({super.key});

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
              icon: Icon(Icons.article),
              label: 'Ingredients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark),
              label: 'Collections',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Reports',
            ),
          ],
        );
      },
    );
  }
}
