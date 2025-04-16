import 'package:supabase_flutter/supabase_flutter.dart';


class RecipeService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final response = await supabase
        .from('recipe')
        .select();
    print(response);
    return List<Map<String, dynamic>>.from(response as List);
  }
}