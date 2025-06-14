import 'package:barmate/model/account_model.dart';
import 'package:barmate/repositories/loggedin_user_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRepository {
  final SupabaseClient client = Supabase.instance.client;
  LoggedinUserProfileRepository loggedinUserProfileRepository =
      LoggedinUserProfileRepository();

  Future<List<Account>> fetchAllUsers() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        print('No user found – cannot fetch accounts.');
        return [];
      }
      
      final response = await client.rpc(
        'get_all_accounts',
        params: {'p_user_id': userId},
      );
      if (response != null) {
        for (final account in response) {
          account['title'] = await loggedinUserProfileRepository.fetchUserTitle(account['userid']);
        }
        return (response as List)
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    }
    return [];
  }
}
