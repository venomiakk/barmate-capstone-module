
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:barmate/data/notifiers.dart';


class AdminNavbar extends StatelessWidget {
  const AdminNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, sekectedPage, child) {
        return CurvedNavigationBar(
          items: const <Widget>[
            Icon(Icons.article, size: 30),
            Icon(Icons.assessment, size: 30),
            Icon(Icons.collections_bookmark, size: 30),
          ],
          onTap: (value) => selectedPageNotifier.value = value,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor:Theme.of(context).scaffoldBackgroundColor,
          animationCurve: Curves.linearToEaseOut,
        );
      },
    );
  }
}
