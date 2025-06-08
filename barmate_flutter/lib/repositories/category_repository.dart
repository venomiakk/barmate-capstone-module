
import 'package:barmate/model/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepository {
  final SupabaseClient client = Supabase.instance.client;


  Future<List<Category>> getEveryCategory() async {
    final response = await client
        .from('ingredient_category')
        .select();

    final List<dynamic> categories = response;

    return categories
        .map((cr) => Category.fromMap(cr))
        .toList();
  }

  Future<Category> getTagByName(String categoryName) async {
    final response = await client
        .from('ingredient_category')
        .select()
        .eq('name', categoryName)
        .single();

    if (response == null) {
      throw Exception('Category not found');
    }

    return Category.fromMap(response);
  }
}