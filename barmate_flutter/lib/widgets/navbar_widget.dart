import 'package:barmate/Utils/colors.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:barmate/data/notifiers.dart';


class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, sekectedPage, child) {
        return CurvedNavigationBar(
          items: const <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.search, size: 30),
            Icon(Icons.person, size: 30),
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
