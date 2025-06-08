import 'package:barmate/model/public_profile_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PublicProfileRepository {
  final SupabaseClient client = Supabase.instance.client;
  var logger = Logger(printer: PrettyPrinter());

  Future<PublicProfileModel> fetchUserData(String userId) async {
    try {
      final response = await client.rpc(
        'get_all_user_data',
        params: {'arg_id': userId},
      );

      // Check if response is empty
      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('User not found');
      }

      // The response is already the data array - no need to access .data
      return PublicProfileModel.fromJson(response[0]);
    } catch (e) {
      logger.e('Error fetching user data: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<List<dynamic>> fetchUserFavoriteDrinks(String userId) async {
    try {
      // Call repository to get the user's favorite drinks
      // logger.w("Fetching favorite drinks for user ID: $userId");
      final response = await client.rpc(
        'get_favourite_drinks_by_user_id',
        params: {'user_id': userId},
      );

      if (response == null) {
        return [];
      }

      // Process response into drink objects
      return response
          .map(
            (drink) => {
              'id': drink['id'],
              'name': drink['drink_name'],
              'recipeId': drink['recipe_id'],
              'imageUrl': drink['photo_url'],
            },
          )
          .toList();
    } catch (e) {
      logger.e("Error fetching user favorite drinks: $e");
      return [];
    }
  }

  Future<List<Recipe>> fetchUsersRecipes(String userId) async {
    try {
      final response = await client.rpc(
        'get_users_recipes',
        params: {'user_id': userId},
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      // Map the response to Recipe objects
      return (response as List<dynamic>)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    } catch (e) {
      logger.e("Error fetching user's recipes: $e");
      return [];
    }
  }
}
