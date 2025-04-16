import 'package:barmate/model/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<RecipeModel>> getRecipesByCollectionName(String collectionName) async {
    // Pobierz ID kolekcji o podanej nazwie
    final collectionResponse = await client
        .from('collection')
        .select('id')
        .eq('name', collectionName)
        .single();

    final collectionId = collectionResponse['id'];

    // Pobierz ID przepisów powiązanych z kolekcją
    final collectionRecipeResponse = await client
        .from('collection_recipe')
        .select('recipe_id')
        .eq('collection_id', collectionId);

    final recipeIds = (collectionRecipeResponse as List)
        .map((item) => item['recipe_id'] as int)
        .toList();

    if (recipeIds.isEmpty) {
      return [];
    }


    final recipesResponse = await client
        .from('recipe')
        .select('id, name')
        .inFilter('id', recipeIds);

    final recipes = (recipesResponse as List)
        .map((item) => RecipeModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return recipes;
  }
}
