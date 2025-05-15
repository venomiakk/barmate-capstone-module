import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/profile_screen.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/favourite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/user_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generuje mocki dla zależności
@GenerateMocks([LoggedinUserProfileController, UserPreferences])
import 'profile_screen_test.mocks.dart';

void main() {
  late MockLoggedinUserProfileController mockController;
  late MockUserPreferences mockUserPreferences;

  setUp(() {
    mockController = MockLoggedinUserProfileController();
    mockUserPreferences = MockUserPreferences();

    // Konfiguracja fabryki kontrolera
    LoggedinUserProfileController.factory = () => mockController;

    // Konfiguracja zachowania mocków kontrolera
    when(mockController.loadUserTitle()).thenAnswer((_) async => 'Test Title');
    when(mockController.getUserBio()).thenAnswer((_) async => 'Test Bio');
    when(mockController.loadFavouriteDrinks()).thenAnswer((_) async {});

    // Zastąpienie instancji UserPreferences mockiem
    UserPreferences.instance = mockUserPreferences;

    // Konfiguracja zachowania mocka UserPreferences
    when(mockUserPreferences.getUserName()).thenReturn('Test User');
    when(mockUserPreferences.getUserId()).thenReturn('test-user-id');
    when(mockUserPreferences.getUserTitle()).thenReturn('Test Title');
  });

  group('UserPage tests', () {
    testWidgets('should load user data on init', (WidgetTester tester) async {
      // Arrange - zastępujemy konstruktor kontrolera mockiem

      // Act - renderujemy widget
      await tester.pumpWidget(MaterialApp(home: UserPage()));
      await tester
          .pumpAndSettle(); // Czekamy na zakończenie animacji i asynchronicznych operacji

      // Assert - sprawdzamy czy metody kontrolera zostały wywołane
      verify(mockController.loadUserTitle()).called(1);
      verify(mockController.getUserBio()).called(1);
      verify(mockController.loadFavouriteDrinks()).called(1);

      // Sprawdzamy czy widget profilu użytkownika jest wyświetlany
      expect(find.byType(UserProfileWidget), findsOneWidget);

      // Sprawdzamy czy lista ulubionych drinków jest wyświetlana
      expect(find.byType(FavouriteDrinksListWidget), findsOneWidget);
    });

    testWidgets('should show user title and bio in UserProfileWidget', (
      WidgetTester tester,
    ) async {
      // Arrange

      // Act
      await tester.pumpWidget(MaterialApp(home: UserPage()));
      await tester.pumpAndSettle();

      // Assert - sprawdzamy, czy UserProfileWidget otrzymuje poprawne dane
      final UserProfileWidget profileWidget = tester.widget(
        find.byType(UserProfileWidget),
      );
      expect(profileWidget.userTitle, 'Test Title');
      expect(profileWidget.userBio, 'Test Bio');
    });

    testWidgets(
      'should call logoutConfiramtionTooltip when logout button is pressed',
      (WidgetTester tester) async {
        // Arrange

        // Act
        await tester.pumpWidget(MaterialApp(home: UserPage()));
        await tester.pumpAndSettle();

        // Znajdujemy przycisk wylogowania
        final logoutButton = find.byIcon(Icons.logout);
        expect(logoutButton, findsOneWidget);

        // Klikamy przycisk
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // Assert - sprawdzamy czy metoda kontrolera została wywołana
        verify(mockController.logoutConfiramtionTooltip(any)).called(1);
      },
    );
  });
}
