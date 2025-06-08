import 'dart:io';

import 'package:barmate/model/ingredient_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IngredientRepository {
  final SupabaseClient client = Supabase.instance.client;
  var logger = Logger(printer: PrettyPrinter());

  Future<Ingredient?> fetchIngredientById(int ingredientId) async {
    try {
      final response = await client.rpc(
        'get_ingredient_by_id',
        params: {'ingredient_id': ingredientId},
      );
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
        return (response as List)
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching ingredient: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>?> fetchIngriedientByRecipeId(
    int recipeId,
  ) async {
    try {
      final response = await client.rpc(
        'get_ingredients_by_recipeId',
        params: {'p_recipe_id': recipeId},
      );
      if (response != null) {
        print(response);
        return (response as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching ingredient: $e');
    }
    return null;
  }

  Future<bool> createIngredient(
    String name,
    String unit,
    File image,
    int category,
    String description,
  ) async {
    String publicUrl = 'init_collection.jpg';
    try {
      final fileExt = image.path.split('.').last;
      final fileName =
          'ingredients/${name.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(RegExp(r'\s+'), '_')}.$fileExt';

      await client.storage
          .from('barmatepics')
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(upsert: true),
          );

      final fullUrl = client.storage.from('barmatepics').getPublicUrl(fileName);

      final uri = Uri.parse(fullUrl);
      final segments = uri.pathSegments;
      publicUrl = segments
          .skipWhile((s) => s != 'barmatepics')
          .skip(1)
          .join('/');
    } catch (e) {
      logger.e('Error uploading image: $e');
      return false;
    }

    logger.d('Relative image path: $publicUrl');

    try {
      final response = await client.rpc(
        'add_ingredient',
        params: {
          'p_name': name,
          'p_unit': unit,
          'p_category': category,
          'p_photo_url': publicUrl,
          'p_description': description,
        },
      );

      if (response != null) {
        logger.d('Collection created with ID: $response');
      }
    } catch (e) {
      logger.e('Error creating collection: $e');
      return false;
    }

    return true;
  }
}
