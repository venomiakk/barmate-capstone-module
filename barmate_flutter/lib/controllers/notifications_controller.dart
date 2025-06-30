import 'package:barmate/model/notifications_model.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get hasUnread => _notifications.any((n) => !n.isRead);

  @visibleForTesting
  void clearAllForTesting() {
    _notifications.clear();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(
      0,
      notification,
    ); // Po prostu dodaj obiekt, który otrzymałeś
    notifyListeners();
  }

  void removeNotification(AppNotification notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void maybeNotifyLowQuantity({
    required String ingredientName,
    required int amount,
    required String unit,
  }) {
    final unitLower = unit.toLowerCase();
    final threshold =
        (unitLower.contains('ml') || unitLower.contains('g')) ? 200 : 2;

    final alreadyNotified = _notifications.any(
      (n) => n.title == "Low on $ingredientName",
    );

    if (amount < threshold && !alreadyNotified) {
      addNotification(
        AppNotification(
          title: "Low on $ingredientName",
          message: "Only $amount $unit left in your stash.",
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}
