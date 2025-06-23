import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/repositories/loggedin_user_profile_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/model/recipe_model.dart';

// --- Klasy-atrapy (mocki) ---

class MockUserProfileRepository extends Mock
    implements LoggedinUserProfileRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockAuthService extends Mock implements AuthService {}

// Mock UserPreferences
class MockUserPreferences extends Mock implements UserPreferences {}

void main() {
  late LoggedinUserProfileController controller;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockRecipeRepository mockRecipeRepository;
  late MockAuthService mockAuthService;
  late MockUserPreferences mockUserPreferences;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 1. Tworzymy wszystkie nasze mocki jako pierwsze
    mockUserProfileRepository = MockUserProfileRepository();
    mockRecipeRepository = MockRecipeRepository();
    mockAuthService = MockAuthService();
    mockUserPreferences = MockUserPreferences();

    UserPreferences.instance = mockUserPreferences;

    // 2. Wstrzykujemy mocki do kontrolera przez jego nowy konstruktor
    //    Problem z Supabase został rozwiązany, bo prawdziwy AuthService nigdy nie jest tworzony!
    controller = LoggedinUserProfileController(
      authService: mockAuthService,
      userProfileRepository: mockUserProfileRepository,
      recipeRepository: mockRecipeRepository,
    );
  });
  group('LoggedinUserProfileController', () {
   
    test('getUserBio zwraca "No bio available" when fails', () async {
      // ARRANGE
      when(() => mockUserPreferences.getUserId()).thenReturn('test-user-id');
      when(
        () => mockUserProfileRepository.fetchUserBio(any()),
      ).thenThrow(Exception('Network error'));

      // ACT
      final result = await controller.getUserBio();

      // ASSERT
      expect(result, 'No bio available');
    });

    test('removeDrink calls repository method', () async {
      // ARRANGE
      // Ustawiamy, aby metoda removeDrink w mocku nic nie robiła (zwracała Future<void>)
      when(
        () => mockUserProfileRepository.removeDrink(any()),
      ).thenAnswer((_) async {});

      // ACT
      await controller.removeDrink(123);

      // ASSERT
      // Weryfikujemy, czy metoda removeDrink z argumentem 123 została wywołana dokładnie raz
      verify(() => mockUserProfileRepository.removeDrink(123)).called(1);
    });

    test('getRecipeById returns recipe when succeded', () async {
      // ARRANGE
      final mockRecipe = Recipe(
        id: 101,
        name: 'Test Recipe',
        description: 'This is a test recipe.',
        ingredients: [],
        photoUrl: 'http://example.com/photo.jpg',
        tags: [],
        creatorId: 'test-creator-id',
        strengthLevel: 3,
        ice: false,
      );
      when(
        () => mockRecipeRepository.getRecipeById(101),
      ).thenAnswer((_) async => mockRecipe);

      // ACT
      final result = await controller.getRecipeById(101);

      // ASSERT
      expect(result, mockRecipe);
    });

    test('getRecipeById throws exception when recipe doesnt exist', () async {
      // ARRANGE
      when(
        () => mockRecipeRepository.getRecipeById(any()),
      ).thenAnswer((_) async => null);

      // ACT & ASSERT
      // Sprawdzamy, czy wywołanie tej funkcji faktycznie rzuci wyjątkiem
      expect(() => controller.getRecipeById(999), throwsA(isA<Exception>()));
    });
  });
}
