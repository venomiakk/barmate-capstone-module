import 'package:barmate/model/collection_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepository {
  final SupabaseClient client = Supabase.instance.client;

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
}
