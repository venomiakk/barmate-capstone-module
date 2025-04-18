import 'package:barmate/data/notifiers.dart';
import 'package:barmate/screens/home_screen.dart';
import 'package:barmate/screens/search_screen.dart';
import 'package:barmate/screens/user_screen.dart';
import 'package:barmate/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

List<Widget> widgetList = [
  HomeScreen(),
  SearchPage(),
  UserPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
        return widgetList.elementAt(selectedPage);
      }),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}