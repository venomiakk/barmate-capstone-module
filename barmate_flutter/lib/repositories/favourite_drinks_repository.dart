import 'package:barmate/model/favourite_drink_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteDrinkRepository {
  final SupabaseClient client = Supabase.instance.client;

  // Funkcja do pobierania ulubionych drinków użytkownika na podstawie jego userId
Future<List<FavouriteDrink>> fetchFavouriteDrinksByUserId(String userId) async {
  try {
    final result = await client.rpc(
      'get_favourite_drinks_by_user_id',
      params: {'user_id': userId},
    );

    if (result == null) {
      throw Exception('No data returned from RPC');
    }

    final List<dynamic> data = result as List<dynamic>;
    return data
        .map((item) => FavouriteDrink.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error fetching favourite drinks: $e');
    rethrow;
  }
}

Future<int> addFavouriteDrink(
  String userId,
  int recipeId,
) async {
  try {
    final response = await client.rpc(
      'add_to_fav',
      params: {
        'p_user_id': userId,
        'p_recipe_id': recipeId,
      },
    );

    if (response == null) {
      throw Exception('No data returned from RPC');
    }

    return response as int;
  } catch (e) {
    print('Error adding favourite drink: $e');
    rethrow;
  }
}
Future<bool> checkIfFavouriteDrinkExists(
  String userId,
  int recipeId,
) async {
  try {
    final response = await client.rpc(
      'ckeck_fav_recipes',
      params: {
        'p_user_id': userId,
        'p_recipe_id': recipeId,
      },
    );

    if (response == null) {
      throw Exception('No data returned from RPC');
    }

    return response as bool;
  } catch (e) {
    print('Error checking if favourite drink exists: $e');
    rethrow;
  }
}

Future<int> removeFavouriteDrink(
  String userId,
  int recipeId,
) async {
  try {
    final response = await client.rpc(
      'remove_from_fav_by_ids',
      params: {
        'p_user_id': userId,
        'p_recipe_id': recipeId,
      },
    );

    if (response == null) {
      throw Exception('No data returned from RPC');
    }

    return response as int;
  } catch (e) {
    print('Error removing favourite drink: $e');
    rethrow;
  }
}
}
