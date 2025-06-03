import 'package:barmate/model/stash_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStashRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<UserStash>> fetchUserStash(var userId) async {
    try {
      print(userId);
      final response = await client.rpc('get_user_stash', params: {'p_user_id': userId});
      print(response);
      if (response != null) {
        return (response as List).map((e) => UserStash.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching user stash: $e');
    }
    return [];
  }

  Future<void> addToStash(var userId, int ingredientId, int quantity) async {
    try {
      final response = await client.rpc('add_to_stash', params: {
        'p_user_id': userId,
        'p_ingredient_id': ingredientId,
        'p_quantity': quantity,
      });
      if (response != null) {
        print('Added to stash: $response');
      }
    } catch (e) {
      print('Error adding to stash: $e');
    }
  }

   Future<void> removeFromStash(var userId, int ingredientId) async {
    try {
      final response = await client.rpc('delete_ingredient_from_stash', params: {
        'p_user_id': userId,
        'p_ingredient_id': ingredientId,
      });
      print('Removed from stash: $response');
    } catch (e) {
      print('Error removing from stash: $e');
    }
  }


  Future<void> changeIngredientAmount(var userId, int ingredientId, int newAmount) async {
  try {
    final response = await client.rpc('change_ingredient_amount_in_stash', params: {
      'p_user_id': userId,
      'p_ingredient_id': ingredientId,
      'p_amount': newAmount,
    });
    print('Amount changed: $response');
  } catch (e) {
    print('Error changing ingredient amount: $e');
  }
}

Future<UserStash?> fetchSingleIngredientFromStash(var userId, int ingredientId) async {
  try {
    final stash = await fetchUserStash(userId);
    return stash.firstWhere(
      (element) => element.ingredientId == ingredientId
    );
  } catch (e) {
    print('Error fetching single stash item: $e');
    return null;
  }
}

}
