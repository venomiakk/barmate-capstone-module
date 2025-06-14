import 'package:barmate/model/recipe_comment_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsRepository {
  var logger = Logger(printer: PrettyPrinter());
  final SupabaseClient client = Supabase.instance.client;

  /// Pobiera komentarz po commentId za pomocą funkcji RPC Supabase
  Future<RecipeComment?> fetchCommentById(int commentId) async {
    try {
      final response = await client.rpc(
        'get_comment_by_id', // <-- tu wpisz nazwę swojej funkcji RPC
        params: {'p_comment_id': commentId},
      );
      if (response != null && response is List && response.isNotEmpty) {
        // Funkcja zwraca listę z jednym elementem
        final json = response.first as Map<String, dynamic>;
        return RecipeComment.fromJson(json);
      }
    } catch (e) {
      print('Error fetching comment by id: $e');
    }
    return null;
  }

  Future<int?> removeComment(int commentId) async {
    try {
      final response = await client.rpc(
        'remove_comment_by_id',
        params: {'p_comment_id': commentId},
      );
      if (response != null) {
        return response as int;
      }
    } catch (e) {
      print('Error removing comment: $e');
    }
    return null;
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
}