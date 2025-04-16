import 'package:barmate/model/collection_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepository {
  final SupabaseClient _client;

  CollectionRepository(this._client);

  Future<List<Collection>> fetchCollections() async {
    final response = await _client
        .from('collection')
        .select()
        .order('id', ascending: true);

    final data = response as List<dynamic>;

    return data.map((item) => Collection.fromJson(item)).toList();
  }
}