import 'package:barmate/model/shopping_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingListRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<ShoppingList>> fetchUserShoppingList() async {
    try {
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        print('Brak użytkownika – nie można pobrać listy zakupów.');
        return [];
      }

      final response = await client.rpc(
        'get_user_shopping_list',
        params: {'user_id_p': userId},
      );

      if (response != null) {
        return (response as List)
            .map((e) => ShoppingList.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching shopping list: $e');
    }
    return [];
  }

  Future<void> deleteFullShoppingList() async {
    try {
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        print('Brak użytkownika – nie można usunąć listy zakupów.');
        return;
      }

      await client.rpc(
        'delete_all_user_shopping_list',
        params: {'p_user_id': userId},
      );

      print('Lista zakupów została usunięta.');
    } catch (e) {
      print('Błąd podczas usuwania listy zakupów: $e');
    }
  }
}
