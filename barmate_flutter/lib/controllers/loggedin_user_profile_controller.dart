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

  Future<String> getUserBio() async {
    try {
      final userId = UserPreferences().getUserId();
      final userBio = await userProfileRepository.fetchUserBio(userId);
      return userBio;
    } catch (e) {
      logger.w(e);
      return 'No bio available';
    }
  }

  Future<String> loadUserTitle() async {
    try {
      final userId = UserPreferences().getUserId();
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
      final userId = UserPreferences().getUserId();
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
      UserPreferences.clear();
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
