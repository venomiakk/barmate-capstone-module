import 'package:barmate/model/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Recipe>> getPopularRecipes() async{
    try {
    final response = await client.rpc('get_popular_recipes');
    if (response != null) {
      return (response as List).map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    print('Error fetching ingredient: $e');
  }
  return [];
  }

  Future<List<Recipe>> getAllRecipes() async{
    try {
    final response = await client.rpc('get_all_recipes');
    if (response != null) {
      return (response as List).map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    print('Error fetching ingredient: $e');
  }
  return [];
  }

Future<List<Recipe>> getRecipesByIngredient(int ingredientId) async {
  try {
    final response = await client.rpc(
      'get_recipes_by_ingredient_id',
      params: {'p_ingredient_id': ingredientId},
    );

    if (response != null) {
      final List<dynamic> data = response;
      return data
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  } catch (e) {
    print('Error fetching recipes by ingredient: $e');
  }
  return [];
}
}
