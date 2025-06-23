import 'package:flutter_test/flutter_test.dart';

// Zmień ścieżkę na właściwą w Twoim projekcie
import 'package:barmate/controllers/notifications_controller.dart';
import 'package:barmate/model/notifications_model.dart';

void main() {
  // Deklarujemy zmienną, która będzie dostępna w całej grupie testów
  late NotificationService notificationService;

  // Funkcja `setUp` uruchamia się przed każdym pojedynczym testem,
  // co gwarantuje, że każdy test zaczyna ze świeżą, czystą instancją serwisu.
  setUp(() {
    // Pobieramy instancję singletona
    notificationService = NotificationService();
    // CZYŚCIMY JEGO STAN PRZED KAŻDYM TESTEM!
    notificationService.clearAllForTesting();
  });

  // Grupujemy wszystkie testy związane z NotificationService
  group('NotificationService Unit Tests', () {
    test('should correctly add a new notification', () {
      // ARRANGE - Przygotuj dane
      final newNotification = AppNotification(
        title: 'Test Title',
        message: 'Test Message',
        timestamp: DateTime.now(),
      );

      // ACT - Wykonaj testowaną metodę
      notificationService.addNotification(newNotification);

      // ASSERT - Sprawdź wynik
      expect(notificationService.notifications.length, 1);
      expect(notificationService.notifications.first.title, 'Test Title');
      // Sprawdzamy, czy nowo dodane powiadomienie jest domyślnie nieprzeczytane
      expect(notificationService.notifications.first.isRead, isFalse);
    });

    test(
      'hasUnread getter should return true when there are unread notifications',
      () {
        // ARRANGE
        notificationService.addNotification(
          AppNotification(
            title: 'Unread',
            message: '...',
            timestamp: DateTime.now(),
          ),
        );

        // ACT & ASSERT
        expect(notificationService.hasUnread, isTrue);
      },
    );

    test(
      'hasUnread getter should return false when all notifications are read',
      () {
        // ARRANGE
        notificationService.addNotification(
          AppNotification(
            title: 'Read',
            message: '...',
            timestamp: DateTime.now(),
            isRead: true,
          ),
        );

        // ACT & ASSERT
        expect(notificationService.hasUnread, isFalse);
      },
    );

    test('markAllAsRead should mark all notifications as read', () {
      // ARRANGE
      notificationService.addNotification(
        AppNotification(title: 'N1', message: '...', timestamp: DateTime.now()),
      );
      notificationService.addNotification(
        AppNotification(title: 'N2', message: '...', timestamp: DateTime.now()),
      );

      // Sprawdzenie warunku początkowego
      expect(notificationService.hasUnread, isTrue);

      // ACT
      notificationService.markAllAsRead();

      // ASSERT
      expect(notificationService.hasUnread, isFalse);
      // Sprawdzamy, czy każdy element na liście ma teraz `isRead = true`
      expect(notificationService.notifications.every((n) => n.isRead), isTrue);
    });

    test('clearAllNotifications should remove all notifications', () {
      // ARRANGE
      notificationService.addNotification(
        AppNotification(title: 'N1', message: '...', timestamp: DateTime.now()),
      );
      notificationService.addNotification(
        AppNotification(title: 'N2', message: '...', timestamp: DateTime.now()),
      );
      expect(notificationService.notifications.length, 2);

      // ACT
      notificationService.clearAllNotifications();

      // ASSERT
      expect(notificationService.notifications.isEmpty, isTrue);
    });

    // Grupujemy testy dla bardziej złożonej metody `maybeNotifyLowQuantity`
    group('maybeNotifyLowQuantity', () {
      test(
        'should add notification when "ml" quantity drops below threshold',
        () {
          // ACT
          notificationService.maybeNotifyLowQuantity(
            ingredientName: 'Vodka',
            amount: 150, // Poniżej progu 200
            unit: 'ml',
          );

          // ASSERT
          expect(notificationService.notifications.length, 1);
          expect(notificationService.notifications.first.title, 'Low on Vodka');
        },
      );

      test(
        'should add notification when "pieces" quantity drops below threshold',
        () {
          // ACT
          notificationService.maybeNotifyLowQuantity(
            ingredientName: 'Lime',
            amount: 1, // Poniżej progu 2
            unit: 'pcs',
          );

          // ASSERT
          expect(notificationService.notifications.length, 1);
          expect(notificationService.notifications.first.title, 'Low on Lime');
        },
      );

      test('should NOT add notification when quantity is above threshold', () {
        // ACT
        notificationService.maybeNotifyLowQuantity(
          ingredientName: 'Vodka',
          amount: 500, // Powyżej progu 200
          unit: 'ml',
        );

        // ASSERT
        expect(notificationService.notifications.isEmpty, isTrue);
      });

      test('should NOT add notification if similar one already exists', () {
        // ARRANGE - dodajmy najpierw istniejące powiadomienie
        notificationService.addNotification(
          AppNotification(
            title: 'Low on Vodka',
            message: '...',
            timestamp: DateTime.now(),
          ),
        );

        // ACT - spróbujmy dodać kolejne
        notificationService.maybeNotifyLowQuantity(
          ingredientName: 'Vodka',
          amount: 50, // Ilość poniżej progu, ale powiadomienie już jest
          unit: 'ml',
        );

        // ASSERT - wciąż powinno być tylko jedno powiadomienie
        expect(notificationService.notifications.length, 1);
      });
    });
  });
}
