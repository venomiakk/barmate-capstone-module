import 'package:barmate/model/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRecipeRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Recipe>> getRecipesByCollectionId(int collectionId) async {
    try {
      final response = await client
          .rpc('get_recipes_by_collection', params: {'p_collection_id': collectionId});
      if (response != null && response is List) {
        return response
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching recipes by collection: $e');
    }
    return [];
  }
}
