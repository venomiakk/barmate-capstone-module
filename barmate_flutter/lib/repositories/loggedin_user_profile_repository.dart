import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoggedinUserProfileRepository {
  final SupabaseClient client = Supabase.instance.client;
  var logger = Logger(printer: PrettyPrinter());

  Future<String> fetchUserBio(var userId) async {
    try {
      final response = await client.rpc(
        'get_user_bio',
        params: {'arg_userid': userId},
      );
      if (response != null) {
        logger.d('User bio fetched successfully: ${response[0]['user_bio']}');
        return response[0]['user_bio'] as String;
      }
    } catch (e) {
      logger.e('Error fetching user bio: $e');
    }
    return 'No bio available';
  }

  Future<String> fetchUserTitle(var userId) async {
    try {
      final response = await client.rpc(
        'get_user_title',
        params: {'arg_userid': userId},
      );
      if (response != null) {
        logger.d(
          'User title fetched successfully: ${response[0]['user_title']}',
        );
        return response[0]['user_title'] as String;
      }
    } catch (e) {
      logger.e('Error fetching user title: $e');
    }
    return 'No title available';
  }
}
