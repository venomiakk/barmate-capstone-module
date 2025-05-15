import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:barmate/repositories/favourite_drinks_repository.dart';
import 'package:barmate/repositories/loggedin_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoggedinUserProfileController {
  final logger = Logger(printer: PrettyPrinter());
  final authService = AuthService();
  final FavouriteDrinkRepository repository = FavouriteDrinkRepository();
  final LoggedinUserProfileRepository userProfileRepository =
      LoggedinUserProfileRepository();

  String? userTitle;
  final List<FavouriteDrink> favouriteDrinks = [];

  // Fabryka do tworzenia instancji
  static LoggedinUserProfileController Function() factory =
      () => LoggedinUserProfileController();

  // Metoda fabryczna
  static LoggedinUserProfileController create() {
    return factory();
  }

  Future<String> getUserBio() async {
    try {
      final prefs = await UserPreferences.getInstance();
      final userId = prefs.getUserId();
      logger.d("User ID: $userId");
      final userBio = await userProfileRepository.fetchUserBio(userId);
      return userBio;
    } catch (e) {
      logger.w(e);
      return 'No bio available';
    }
  }

  Future<String> loadUserTitle() async {
    try {
      final prefs = await UserPreferences.getInstance();
      final userId = prefs.getUserId();
      final title = await userProfileRepository.fetchUserTitle(userId);
      userTitle = title;
      return title;
    } catch (e) {
      logger.w(e);
      return 'No title available';
    }
  }

  Future<void> loadFavouriteDrinks() async {
    try {
      final prefs = await UserPreferences.getInstance();
      final userId = prefs.getUserId();
      final drinks = await repository.fetchFavouriteDrinksByUserId(userId);
      favouriteDrinks.clear();
      favouriteDrinks.addAll(drinks);
    } catch (e) {
      logger.w(e);
    }
  }

  void removeFavouriteDrink(int index) {
    if (index >= 0 && index < favouriteDrinks.length) {
      favouriteDrinks.removeAt(index);
    }
  }

  Future<void> logout(BuildContext context) async {
    resetNotifiersToDefaults();
    try {
      final prefs = await UserPreferences.getInstance();
      prefs.clear();
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> logoutConfiramtionTooltip(BuildContext context) async {
    // create tooltip with confirmation message

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
    // implement logout functionality
    if (result == true) {
      await logout(context);
    } else {
      logger.d("Logout cancelled");
    }
  }
}
