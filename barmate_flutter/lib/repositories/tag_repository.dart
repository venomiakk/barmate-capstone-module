
import 'package:barmate/model/tag_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagRepository {
  final SupabaseClient client = Supabase.instance.client;


  Future<List<TagModel>> getEveryTag() async {
    final response = await client
        .from('tag')
        .select();

    final List<dynamic> tags = response;

    return tags
        .map((cr) => TagModel.fromMap(cr))
        .toList();
  }

  Future<TagModel> getTagByName(String tagName) async {
    final response = await client
        .from('tag')
        .select()
        .eq('name', tagName)
        .single();

    if (response == null) {
      throw Exception('Tag not found');
    }

    return TagModel.fromMap(response);
  }
}