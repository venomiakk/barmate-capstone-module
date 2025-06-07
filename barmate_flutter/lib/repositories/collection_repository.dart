import 'dart:ffi';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepository {
  final SupabaseClient client = Supabase.instance.client;
  var logger = Logger(printer: PrettyPrinter());
  var uuid = Uuid();


  Future<List<Collection>> getCollections() async {
    try {
      final response = await client.rpc('get_all_collections');
      if (response != null) {
        return (response as List)
            .map((e) => Collection.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching collections: $e');
    }
    return [];
  }

  Future<bool> createCollection(
    String name,
    String description,
    File? image,
    DateTime endDate,
    List<Recipe> recipes,
  ) async {
    String publicUrl = 'drink_init.jpg';

    if (image != null) {
      try {
        final fileName = 'collections/${uuid.v4()}.${image.path.split('.').last}';

        await client.storage
            .from('barmatepics')
            .upload(
              fileName,
              image,
              fileOptions: const FileOptions(upsert: true),
            );

        final fullUrl = client.storage
            .from('barmatepics')
            .getPublicUrl(fileName);

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

    logger.d('Relative image path: $publicUrl');

    int collectionId = 0;

    try {
      final response = await client.rpc(
        'add_collection',
        params: {
          'p_name': name,
          'p_image_url': publicUrl,
          'p_description': description,
          'p_end_date': endDate.toIso8601String(),
        },
      );

      if (response != null) {
        logger.d('Collection created with ID: $response');
        collectionId = response;
      }
    } catch (e) {
      logger.e('Error creating collection: $e');
      return false;
    }

    try{
      for (var recipe in recipes) {
        final response = await client.rpc(
          'add_recipe_to_collection',
          params: {
            'p_recipe_id': recipe.id,
            'p_collection_id': collectionId,
          },
        );

        if (response == null) {
          logger.e('Failed to add recipe ${recipe.id} to collection $collectionId');
          return false;
        }
      }
    } catch (e) {
      logger.e('Error adding recipes to collection: $e');
      return false;
    }

    return true;
  }
}
