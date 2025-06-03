import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:barmate/repositories/loggedin_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:barmate/constants.dart' as constants;

class LoggedinUserProfileController {
  final logger = Logger(printer: PrettyPrinter());
  final authService = AuthService();
  final LoggedinUserProfileRepository userProfileRepository =
      LoggedinUserProfileRepository();

  String? userTitle;
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
      // logger.d("User ID: $userId");
      final userBio = await userProfileRepository.fetchUserBio(userId);
      return userBio;
    } catch (e) {
      logger.w("Error fetching user bio: $e");
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
      logger.w("Error fetching user title: $e");
      return 'No title available';
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
      // logger.d("Logout cancelled");
    }
  }

  Future<String> loadUserAvatarUrl() async {
    try {
      final prefs = await UserPreferences.getInstance();
      final userId = prefs.getUserId();
      final avatarName = await userProfileRepository.fetchUserAvatar(userId);
      final avatarUrl = '${constants.picsBucketUrl}/$avatarName';
      return avatarUrl;
    } catch (e) {
      logger.w("Error fetching user avatar: $e");
      return 'No avatar available';
    }
  }

  Future<List<FavouriteDrink>> loadUserFavouriteDrinks() async {
    try {
      final prefs = await UserPreferences.getInstance();
      final userId = prefs.getUserId();
      final drinks = await userProfileRepository.fetchUserFavouriteDrinks(
        userId,
      );
      // change to List<FavouriteDrink>
      final favouriteDrinks =
          drinks.map((drink) => FavouriteDrink.fromJson(drink)).toList();
      // logger.i("User favourite drinks: $favouriteDrinks");
      return favouriteDrinks;
      // return drinks.cast<FavouriteDrink>();
    } catch (e) {
      logger.w("Error fetching user favourite drinks: $e");
      return [];
    }
  }

  Future<void> removeDrink(int drinkId) async {
    try {
      await userProfileRepository.removeDrink(drinkId);
    } catch (e) {
      logger.w("Error removing drink: $e");
    }
  }
}
