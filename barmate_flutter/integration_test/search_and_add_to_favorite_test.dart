import 'package:barmate/controllers/notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dqgprtjilznvtezvihww.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxZ3BydGppbHpudnRlenZpaHd3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjkxMTAwOCwiZXhwIjoyMDU4NDg3MDA4fQ.uJAtHRsLeDJCV2sRrSriH7MqJSoNPYz5dU3ZRq3O9dY',
    );
  });

  group('E2E - User route', () {
    testWidgets(
      'login, search for a recipe, and add it to favorites',
      (WidgetTester tester) async {
        // --- ARRANGE ---
        // Uruchomienie aplikacji. Używamy tu strategii z uruchomieniem MyApp,
        // aby uniknąć podwójnej inicjalizacji Supabase.
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => NotificationService()),
            ],
            child: const app.MyApp(),
          ),
        );

        // Czekamy, aż aplikacja się załaduje i splash screen będzie widoczny.
        await tester.pumpAndSettle();

        // --- ACT & ASSERT ---

        // ==========================================================
        // Krok 1: Nawigacja ze Splash Screen do ekranu logowania
        // ==========================================================
        print('Krok 1: Nawigacja do ekranu logowania...');
        final navigateToSignInButton = find.byKey(
          const Key('navigate_to_sign_in_button'),
        );
        expect(
          navigateToSignInButton,
          findsOneWidget,
          reason: 'Nie znaleziono przycisku "Sign In" na ekranie powitalnym',
        );
        await tester.tap(navigateToSignInButton);
        await tester.pumpAndSettle();

        // ==========================================================
        // Krok 2: Logowanie użytkownika
        // ==========================================================
        print('Krok 2: Logowanie...');
        final emailField = find.byKey(const Key('signin_email_field'));
        final passwordField = find.byKey(const Key('signin_password_field'));
        final signInButton = find.byKey(const Key('signin_button'));

        expect(
          emailField,
          findsOneWidget,
          reason: 'Nie znaleziono pola na email',
        );
        expect(
          passwordField,
          findsOneWidget,
          reason: 'Nie znaleziono pola na hasło',
        );
        expect(
          signInButton,
          findsOneWidget,
          reason: 'Nie znaleziono przycisku "Sign In"',
        );

        await tester.enterText(emailField, 'user11@email.com');
        await tester.enterText(passwordField, 'password');

        await tester.tap(signInButton);
        // Czekamy na zakończenie logowania i animacji przejścia
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // ==========================================================
        // Krok 3: Przejście do ekranu wyszukiwania
        // ==========================================================
        print('Krok 3: Przejście do wyszukiwarki...');
        final searchIconFinder = find.byIcon(Icons.search);
        expect(
          searchIconFinder,
          findsOneWidget,
          reason: 'Nie znaleziono ikony wyszukiwania na dolnym pasku nawigacji',
        );
        await tester.tap(searchIconFinder);
        await tester.pumpAndSettle();

        // ==========================================================
        // Krok 4: Wyszukanie przepisu
        // ==========================================================
        print('Krok 4: Wyszukiwanie "Mojito"...');
        final searchBarFinder = find.byKey(const Key('search_bar'));
        expect(
          searchBarFinder,
          findsOneWidget,
          reason: 'Nie znaleziono pola wyszukiwania na ekranie SearchPage',
        );
        await tester.enterText(searchBarFinder, 'Mojito');
        print('Czekanie na wyniki wyszukiwania...');
        await tester.pump(const Duration(seconds: 3));
        // Po odczekaniu, pumpAndSettle() upewni się, że wszystkie animacje (np. pojawienie się listy) się zakończyły.
        await tester.pumpAndSettle();

        // ==========================================================
        // Krok 5: Znalezienie karty przepisu i przejście do szczegółów
        // ==========================================================
        print('Krok 5: Otwieranie szczegółów przepisu...');
        // Zakładamy, że ID dla Mojito to np. 1. Jeśli jest inne, to też zadziała,
        // o ile znajdziemy kartę po tekście. Użyjemy find.text jako alternatywy.
        final recipeCardTextFinder =
            find.textContaining('MOJITO', findRichText: true).first;
        expect(
          recipeCardTextFinder,
          findsOneWidget,
          reason: 'Nie znaleziono karty z przepisem "MOJITO" po wyszukaniu',
        );
        await tester.tap(recipeCardTextFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // ==========================================================
        // Krok 6: Dodanie do ulubionych na ekranie przepisu
        // ==========================================================
        print('Krok 6: Dodawanie/usuwanie z ulubionych...');
        final favoriteButtonFinder = find.byKey(const Key('favorite_button'));
        expect(
          favoriteButtonFinder,
          findsOneWidget,
          reason: 'Nie znaleziono przycisku ulubionych na ekranie przepisu',
        );

        final iconFinder = find.descendant(
          of: favoriteButtonFinder,
          matching: find.byType(Icon),
        );
        final initialIcon = tester.widget<Icon>(iconFinder);
        final isInitiallyFavorite = initialIcon.icon == Icons.favorite;

        await tester.tap(favoriteButtonFinder);
        await tester.pumpAndSettle();

        final updatedIcon = tester.widget<Icon>(iconFinder);
        if (isInitiallyFavorite) {
          expect(
            updatedIcon.icon,
            Icons.favorite_border,
            reason: 'Ikona nie zmieniła się na "nieulubione"',
          );
          print('Test zakończony sukcesem: Usunięto z ulubionych.');
        } else {
          expect(
            updatedIcon.icon,
            Icons.favorite,
            reason: 'Ikona nie zmieniła się na "ulubione"',
          );
          print('Test zakończony sukcesem: Dodano do ulubionych.');
        }
      },
    );
  });
}
