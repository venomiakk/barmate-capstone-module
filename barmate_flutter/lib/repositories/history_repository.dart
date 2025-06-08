import 'package:barmate/model/user_history_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// można to przenieść do history_recipes_repository.dart xD
class HistoryRepository {
  final SupabaseClient client = Supabase.instance.client;
  final Logger logger = Logger(printer: PrettyPrinter());

  Future<List<UserHistoryModel>> fetchUserHistory(String userId, DateTime startDate) async {
    try {
      final response = await client.rpc(
        'get_user_history',
        params: {'p_userid': userId , 'p_startdate': startDate.toIso8601String()}, 
      );
      if (response != null) {
        return (response as List)
            .map((e) => UserHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }

     
    } catch (e) {
      throw Exception('Failed to fetch user history: $e');
    }
  }
}