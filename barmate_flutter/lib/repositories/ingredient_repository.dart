import 'package:barmate/model/ingredient_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IngredientRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<Ingredient?> fetchIngredientById(int ingredientId) async {
  try {
    final response = await client.rpc('get_ingredient_by_id', params: {'ingredient_id': ingredientId});
    if (response != null) {
      return Ingredient.fromJson(response as Map<String, dynamic>);
    }
  } catch (e) {
    print('Error fetching ingredient: $e');
  }
  return null;
}

Future<List<Ingredient>> fetchAllIngredients() async {
  try {
    final response = await client.rpc('get_all_ingredients');
    if (response != null) {
      return (response as List).map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    print('Error fetching ingredient: $e');
  }
  return [];
  }
}
