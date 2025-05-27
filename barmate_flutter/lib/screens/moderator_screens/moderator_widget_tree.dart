import 'package:barmate/data/notifiers.dart';
import 'package:barmate/screens/admin_screens/create_collection.dart';
import 'package:barmate/screens/moderator_screens/check_reports_screen.dart';
import 'package:barmate/widgets/moderator_navbar.dart';
import 'package:flutter/material.dart';

List<Widget> widgetList = [
  CheckReportsScreen(),
  CreateCollection()
];

class ModeratorWidgetTree extends StatelessWidget {
  const ModeratorWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
        return widgetList.elementAt(selectedPage);
      }),
      bottomNavigationBar: ModeratorNavbar(),
    );
  }
}