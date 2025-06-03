import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoggedinUserProfileRepository {
  final SupabaseClient client = Supabase.instance.client;
  var logger = Logger(printer: PrettyPrinter());

  Future<String> fetchUserBio(var userId) async {
    try {
      final response = await client.rpc(
        'get_user_bio',
        params: {'arg_userid': userId},
      );
      if (response != null) {
        // logger.d('User bio fetched successfully: ${response[0]['user_bio']}');
        return response[0]['user_bio'] as String;
      }
    } catch (e) {
      logger.e('Error fetching user bio: $e');
    }
    return 'No bio available';
  }

  Future<String> fetchUserTitle(var userId) async {
    try {
      final response = await client.rpc(
        'get_user_title',
        params: {'arg_userid': userId},
      );
      if (response != null) {
        // logger.d(
        //   'User title fetched successfully: ${response[0]['user_title']}',
        // );
        return response[0]['user_title'] as String;
      }
    } catch (e) {
      logger.e('Error fetching user title: $e');
    }
    return 'No title available';
  }

  Future<String> fetchUserAvatar(var userId) async {
    try {
      final response = await client.rpc(
        'get_user_avatar',
        params: {'arg_userid': userId},
      );
      if (response != null) {
        // logger.d(
        //   'User avatar fetched successfully: ${response[0]['user_avatar']}',
        // );
        return response[0]['avatar_url'] as String;
      }
    } catch (e) {
      logger.e('Error fetching user avatar: $e');
    }
    return 'No avatar available';
  }

  Future<List<dynamic>> fetchUserFavouriteDrinks(var userId) async {
    try {
      final response = await client.rpc(
        'get_favourite_drinks_by_user_id',
        params: {'user_id': userId},
      );
      if (response != null) {
        // logger.d('User favourite drinks fetched successfully: $response');
        return response;
      }
    } catch (e) {
      logger.e('Error fetching user favourite drinks: $e');
    }
    return [];
  }

  Future<void> removeDrink(int drinkId) async {
    try {
      final response = await client.rpc(
        'remove_from_fav_recipe',
        params: {'arg_joinid': drinkId},
      );
      if (response != null) {
        // logger.d('Drink removed from favourites successfully: $response');
      }
    } catch (e) {
      logger.e('Error removing drink from favourites: $e');
    }
  }
}
