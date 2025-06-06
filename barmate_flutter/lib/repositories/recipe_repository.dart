

import 'package:barmate/model/recipe_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeRepository {
  var logger = Logger(printer: PrettyPrinter());
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Recipe>> getPopularRecipes() async {
    try {
      final response = await client.rpc('get_popular_recipes');
      if (response != null) {
        return (response as List)
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching ingredient: $e');
    }
    return [];
  }

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await client.rpc('get_all_recipes');
      if (response != null) {
        return (response as List)
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
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

  Future<List<Map<String, dynamic>>?> fetchRecipeStepsByRecipeId(
    int recipeId,
  ) async {
    try {
      final response = await client.rpc(
        'get_recipe_steps_by_recipe_id',
        params: {'p_recipe_id': recipeId},
      );

      if (response != null) {
        return (response as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching recipe steps: $e');
    }
    return [];
  }

  Future<void> addCommentToRecipe(
    int p_recipe_id,
    String p_photo_url,
    int p_rating,
    String p_comment,
    String p_user_id,
  ) async {
    try {
      final response = await client.rpc(
        'add_comment_to_recipe',
        params: {
          'p_recipe_id': p_recipe_id,
          'p_photo_url': p_photo_url,
          'p_rating': p_rating,
          'p_comment': p_comment,
          'p_user_id': p_user_id,
        },
      );
      if (response != null) {
        // logger.d('Drink removed from favourites successfully: $response');
      }
    } catch (e) {
      logger.e('Error removing drink from favourites: $e');
    }
  }

   Future<List<Map<String, dynamic>>?> fetchCommentsByRecipeId(
    int recipeId,
  ) async {
    try {
      final response = await client.rpc(
        'get_comments_by_recipe_id',
        params: {'p_recipe_id': recipeId},
      );

      if (response != null) {
        return (response as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching recipe steps: $e');
    }
    return [];
  }

  Future<dynamic> getRecipeById(int recipeId) async {
    try {
      final response = await client.rpc(
        'getRecipeById',
        params: {'recipe_id': recipeId},
      );

      if (response != null && response is Map<String, dynamic>) {
        return Recipe.fromJson(response);
      }
    } catch (e) {
      print('Error fetching recipe by ID: $e');
    }
    return null;
  }

 
}
