import 'package:barmate/data/notifiers.dart';
import 'package:barmate/screens/admin_screens/add_ingredient.dart';
import 'package:barmate/screens/admin_screens/collections.dart';
import 'package:barmate/screens/admin_screens/generate_raport.dart';
import 'package:barmate/widgets/admin_navBar.dart';
import 'package:flutter/material.dart';

List<Widget> widgetList = [
  AddIngredient(),
  Collections(),
  GenerateRaport(),
];

class AdminWidgetTree extends StatelessWidget {
  const AdminWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
        return widgetList.elementAt(selectedPage);
      }),
      bottomNavigationBar: AdminNavbar(),
    );
  }
}