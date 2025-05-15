
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
}