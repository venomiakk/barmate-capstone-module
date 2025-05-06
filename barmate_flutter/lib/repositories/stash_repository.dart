import 'package:barmate/model/stash_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStashRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<UserStash>> fetchUserStash(var userId) async {
    try {
      print(userId);
      final response = await client.rpc('get_user_stash', params: {'p_user_id': userId});
      print(response);
      if (response != null) {
        return (response as List).map((e) => UserStash.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching user stash: $e');
    }
    return [];
  }

}
