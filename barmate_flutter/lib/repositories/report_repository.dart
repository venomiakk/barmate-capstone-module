import 'package:barmate/model/category_model.dart';
import 'package:barmate/model/report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class ReportRepository {
  final SupabaseClient client = Supabase.instance.client;
  final Logger logger = Logger();

  Future<int?> addReport(int? p_recipe_id, int? p_comment_id, String user_id) async {
    // Walidacja: dokładnie jeden z argumentów musi być null
    if ((p_recipe_id == null && p_comment_id == null) ||
        (p_recipe_id != null && p_comment_id != null)) {
      throw ArgumentError('Dokładnie jeden z argumentów musi być null.');
    }
    try {
      final response = await client.rpc(
        'add_report',
        params: {
          'p_recipe_id': p_recipe_id,
          'p_comment_id': p_comment_id,
          'p_user_id': user_id,
        },
      );
      if (response != null) {
        return response as int;
      }
    } catch (e) {
      logger.e('Error removing drink from favourites: $e');
    }
    return null;
  }

  Future<List<Report>> fetchReports() async {
    try {
      final response = await client.rpc('get_all_reports');
      if (response != null && response is List) {
        return response
            .map((json) => Report.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      logger.e('Error fetching reports: $e');
    }
    try {
      final response = await client.rpc('get_all_reports');
      if (response != null && response is List) {
        return response
            .map((json) => Report.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      logger.e('Error getting report: $e');
    }
    return [];
  }

  Future<int?> removeReport(int reportId) async {
    try {
      final response = await client.rpc(
        'remove_report_by_id',
        params: {'p_report_id': reportId},
      );
      if (response != null) {
        return response as int;
      }
    } catch (e) {
      logger.e('Error removing report: $e');
    }
    return null;
  }
}
