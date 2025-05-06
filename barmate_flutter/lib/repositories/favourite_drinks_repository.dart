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
}
