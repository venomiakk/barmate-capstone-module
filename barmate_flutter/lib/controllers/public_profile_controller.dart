import 'package:barmate/model/public_profile_model.dart';
import 'package:barmate/repositories/public_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PublicUserProfileController {
  final Logger logger = Logger(printer: PrettyPrinter());
  final PublicProfileRepository publicProfileRepository =
      PublicProfileRepository();

  static PublicUserProfileController Function() factory =
      () => PublicUserProfileController();

  static PublicUserProfileController create() {
    return factory();
  }

  Future<PublicProfileModel> getUserData(String userId) async {
    try {
      return await publicProfileRepository.fetchUserData(userId);
    } catch (e) {
      logger.e("Error fetching user data: $e");
      throw Exception("Failed to fetch user data");
    }
  }

  Future<bool> followUser(String userId) async {
    // TODO: Implement API call to follow a user
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Return success
      return true;
    } catch (e) {
      logger.e("Error following user: $e");
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    // TODO: Implement API call to unfollow a user
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Return success
      return true;
    } catch (e) {
      logger.e("Error unfollowing user: $e");
      return false;
    }
  }

  Future<List<dynamic>> getUserFavoriteDrinks(String userId) async {
    try {
      List<dynamic> drinks = await publicProfileRepository
          .fetchUserFavoriteDrinks(userId);
      
      return drinks;
    } catch (e) {
      logger.e("Error fetching user favorite drinks: $e");
      throw Exception("Failed to fetch user favorite drinks");
    }
  }
}
