import 'package:barmate/model/user_history_model.dart';
import 'package:barmate/repositories/history_repository.dart';
import 'package:logger/logger.dart';

class UserHistoryController {
  final Logger logger = Logger(printer: PrettyPrinter());

  HistoryRepository historyRepository = HistoryRepository();

  static UserHistoryController Function() factory =
      () => UserHistoryController();

  static UserHistoryController create() {
    return factory();
  }

  Future<List<UserHistoryModel>> getUserHistory(
    String userId,
    DateTime startDate,
  ) async {
    try {
      // Simulate fetching user history from a repository
      List<UserHistoryModel> history = await historyRepository.fetchUserHistory(
        userId,
        startDate,
      );
      if (history.isNotEmpty) {
        return history;
      }
      
      return [];
    } catch (e) {
      logger.e("Error fetching user history: $e");
      throw Exception("Failed to fetch user history");
    }
  }
}
