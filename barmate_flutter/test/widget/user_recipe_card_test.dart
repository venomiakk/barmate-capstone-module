import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:barmate/screens/user_screens/profile/widgets/users_recipe_card.dart';

// Definiujemy stałą, żeby uniknąć błędu kompilacji
class Constants {
  static const picsBucketUrl = 'https://example.com/images';
}

// Klasa do mockowania funkcji zwrotnych (callbacks)
class MockVoidCallback extends Mock {
  void call();
}

void main() {
  // Przygotowanie danych testowych, które będą używane w wielu testach
  final testRecipe = UserRecipe(
    id: 1,
    recipeId: 101,
    name: 'Mojito Klasyczne',
    imageUrl: 'mojito.png',
  );

  // Funkcja pomocnicza do budowania widżetu w środowisku testowym
  Future<void> pumpWidget(WidgetTester tester, Widget widget) async {
    // Musimy opakować nasz widżet w MaterialApp, aby miał dostęp do Theme
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: widget))),
    );
  }

  // Grupujemy testy związane z UserRecipeCard
  group('UserRecipeCard', () {
    testWidgets('correctly shows recipe name', (WidgetTester tester) async {
      // ARRANGE: Budujemy widżet z naszymi danymi testowymi
      await pumpWidget(tester, UserRecipeCard(recipe: testRecipe));

      // ASSERT: Sprawdzamy, czy tekst 'Mojito Klasyczne' jest widoczny na ekranie
      expect(find.text('Mojito Klasyczne'), findsOneWidget);
    });

    testWidgets('correctly shows image', (WidgetTester tester) async {
      // Używamy mockNetworkImagesFor, aby przechwycić zapytania sieciowe
      await mockNetworkImagesFor(() async {
        // ARRANGE
        await pumpWidget(tester, UserRecipeCard(recipe: testRecipe));

        // ACT & ASSERT
        // Znajdujemy widget Image i sprawdzamy, czy jego źródłem jest NetworkImage
        final imageWidget = tester.widget<Image>(find.byType(Image));
        expect(imageWidget.image, isA<NetworkImage>());
      });
    });

    testWidgets('Callback after card onTap', (WidgetTester tester) async {
      // ARRANGE
      final mockOnTap = MockVoidCallback();
      await pumpWidget(
        tester,
        UserRecipeCard(recipe: testRecipe, onTap: mockOnTap),
      );

      // ACT: Symulujemy dotknięcie widżetu
      await tester.tap(find.byType(UserRecipeCard));

      // ASSERT: Weryfikujemy, czy nasza mockowana funkcja została wywołana dokładnie 1 raz
      verify(() => mockOnTap()).called(1);
    });

    testWidgets('displays and supports delete button, when its on', (
      WidgetTester tester,
    ) async {
      // ARRANGE
      final mockOnRemove = MockVoidCallback();
      await pumpWidget(
        tester,
        UserRecipeCard(
          recipe: testRecipe,
          onRemove: mockOnRemove,
          showRemoveButton: true,
        ),
      );

      // ASSERT 1: Sprawdzamy, czy ikona 'close' jest widoczna
      expect(find.byIcon(Icons.close), findsOneWidget);

      // ACT: Symulujemy dotknięcie ikony usuwania
      await tester.tap(find.byIcon(Icons.close));

      // ASSERT 2: Weryfikujemy, czy funkcja onRemove została wywołana
      verify(() => mockOnRemove()).called(1);
    });

    testWidgets('doesnt show delete button, when its off', (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await pumpWidget(
        tester,
        UserRecipeCard(
          recipe: testRecipe,
          onRemove: () {},
          showRemoveButton: false,
        ),
      );

      // ASSERT: Sprawdzamy, czy ikona 'close' NIE jest widoczna
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows frame when isSelected is true', (
      WidgetTester tester,
    ) async {
      // ARRANGE
      await pumpWidget(
        tester,
        UserRecipeCard(recipe: testRecipe, isSelected: true),
      );

      // ACT: Znajdujemy kontener po jego unikalnym kluczu
      final containerFinder = find.byKey(
        const Key('user_recipe_card_container'),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      // ASSERT: Sprawdzamy, czy jego właściwość 'border' nie jest nullem
      expect(
        containerFinder,
        findsOneWidget,
      ); // Dobra praktyka: upewnij się, że finder coś znalazł
      expect(decoration.border, isNotNull);
      expect(decoration.border, isA<Border>());
    });

    group('in delete mode (isDeleteMode)', () {
      testWidgets('shows uncheck icon, doesnt show X', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        await pumpWidget(
          tester,
          UserRecipeCard(
            recipe: testRecipe,
            isDeleteMode: true,
            isSelected: false,
            onRemove: () {},
          ),
        );

        // ASSERT
        expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsNothing);
        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('shows check icon when element is selected', (
        WidgetTester tester,
      ) async {
        // ARRANGE
        await pumpWidget(
          tester,
          UserRecipeCard(
            recipe: testRecipe,
            isDeleteMode: true,
            isSelected: true,
          ),
        );

        // ASSERT
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      });
    });
  });
}
