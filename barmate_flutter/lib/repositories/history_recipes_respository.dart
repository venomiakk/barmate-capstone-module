import 'package:supabase_flutter/supabase_flutter.dart';

class DrinkHistoryRepository {
  final SupabaseClient client = Supabase.instance.client;

  // Funkcja do pobierania ulubionych drinków użytkownika na podstawie jego userId


Future<int> addRecipesToHistory(
  String userId,
  int recipeId,
) async {
  try {
    final response = await client.rpc(
      'add_to_history_recipes',
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
Future<bool> checkIfHisotryRecipesExists(
  String userId,
  int recipeId,
) async {
  try {
    final response = await client.rpc(
      'check_history_recipes',
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

Future<int> removeRecipeFromHistory(
  String userId,
  int recipeId,
) async {
  try {
    final response = await client.rpc(
      'remove_from_history_by_ids',
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
    print('Error removing recipe from history: $e');
    rethrow;
  }
}
}
