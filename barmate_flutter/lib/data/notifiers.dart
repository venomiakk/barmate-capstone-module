import 'package:flutter/material.dart';
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> themeNotifier = ValueNotifier(true);

void resetNotifiersToDefaults() {
  selectedPageNotifier.value = 0;
  themeNotifier.value = true;
}