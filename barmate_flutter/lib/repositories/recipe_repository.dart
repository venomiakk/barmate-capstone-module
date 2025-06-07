import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/tag_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeRepository {
  var logger = Logger(printer: PrettyPrinter());
  final SupabaseClient client = Supabase.instance.client;

  var uuid = Uuid();

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

  Future<bool> addRecipe(
    String name,
    String description,
    File? photoUrl,
    String userId,
    List<Map<String, dynamic>> ingredients,
    List<String> steps,
    bool hasIce,
    int strength,
    List<TagModel> tags,
  ) async {
    String publicUrl = 'drink_init.jpg';

    if (photoUrl != null) {
      try {
        final fileName = 'drinks/${uuid.v4()}.${photoUrl.path.split('.').last}';

        await client.storage
            .from('barmatepics')
            .upload(
              fileName,
              photoUrl,
              fileOptions: const FileOptions(upsert: true),
            );

        // Pobierz pełny publiczny URL
        final fullUrl = client.storage
            .from('barmatepics')
            .getPublicUrl(fileName);

        // Wyodrębnij tylko ścieżkę względną z URL-a
        final uri = Uri.parse(fullUrl);
        final segments = uri.pathSegments;
        publicUrl = segments
            .skipWhile((s) => s != 'barmatepics')
            .skip(1)
            .join('/');
      } catch (e) {
        logger.e('Error uploading image: $e');
      }
    }

    print('Relative image path: $publicUrl');

    int recipeId = 0;

    try {
      final response = await client.rpc(
        'add_recipe',
        params: {
          'p_name': name,
          'p_photo_url': publicUrl,
          'p_description': description,
          'p_strength': strength,
          'p_has_ice': hasIce,
          'p_user_id': userId,
        },
      );

      if (response != null) {
        logger.d('Recipe added successfully: $response');
        recipeId = response;
      }
    } catch (e) {
      logger.e('Error adding recipe: $e');
      return false;
    }

    try {
      for (final ingredient in ingredients) {
        final response = await client.rpc(
          'add_ingredient_to_recipe',
          params: {
            'p_ingredient_id': ingredient['id'],
            'p_recipe_id': recipeId,
            'p_amount': ingredient['amount'],
          },
        );

        if (response != null) {
          logger.d('Ingredient added to recipe successfully: $response');
        }
      }
    } catch (e) {
      logger.e('Error adding ingredient to recipe: $e');
      return false;
    }

    try {
      int order = 1;
      for (final step in steps) {
        final response = await client.rpc(
          'add_step_to_recipe',
          params: {
            'p_recipe_id': recipeId,
            'p_order': order,
            'p_description': step,
          },
        );

        if (response != null) {
          logger.d('Step added to recipe successfully: $response');
          order++;
        }
      }
    } catch (e) {
      logger.e('Error adding step to recipe: $e');
      return false;
    }

    try {
      for (final tag in tags) {
        final response = await client.rpc(
          'add_tag_to_recipe',
          params: {'p_recipe_id': recipeId, 'p_tag_id': tag.id},
        );

        if (response != null) {
          logger.d('Tag added to recipe successfully: $response');
        }
      }
    } catch (e) {
      logger.e('Error adding tag to recipe: $e');
      return false;
    }

    return true;
  }
}
