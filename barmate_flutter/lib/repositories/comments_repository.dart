import 'package:barmate/model/recipe_comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsRepository {
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
}