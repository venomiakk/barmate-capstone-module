import 'package:barmate/constants.dart' as constatns;
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/collection_repository.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:barmate/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Collection>> _collectionsList;
  late Future<List<Recipe>> _popularRecipesFuture;
  final RecipeRepository recipeRepository = RecipeRepository();
  final CollectionRepository collectionRepository = CollectionRepository();

  String? selectedTag; // State to track the selected tag

  @override
  void initState() {
    super.initState();
    _collectionsList = collectionRepository.getCollections();
    _popularRecipesFuture = recipeRepository.getPopularRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30),
              collectionListWidget<Collection>(
                title: 'Featured',
                future: _collectionsList,
                getName: (collection) => collection.name,
                getPhotoUrl: (collection) => collection.photoUrl ?? '',
              ),
              const SizedBox(height: 30),
              popularRecipes(),
            ],
          ),
        ),
      ),
    );
  }

  // Uniwersalny widget do wyświetlania karty przepisu
  Widget recipeCard(Recipe recipe, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child:
                    recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty
                        ? Image.network(
                          '${constatns.picsBucketUrl}/${recipe.photoUrl!}',
                          height: 110,
                          width: 150,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Image.asset(
                                'images/default_recipe_image.jpg',
                                height: 110,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          'images/default_recipe_image.jpg',
                          height: 110,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Uniwersalny widget do wyświetlania kolekcji
  Widget collectionListWidget<T>({
    required String title,
    required Future<List<T>> future,
    required String Function(T) getName,
    String? Function(T)? getPhotoUrl, // Dodane: funkcja do pobrania photo_url
    Recipe? Function(T)? getRecipe,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No $title available.');
        } else {
          final items = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    // Jeśli getRecipe jest podany i zwraca Recipe, wyświetl kartę przepisu
                    if (getRecipe != null) {
                      final recipe = getRecipe(item);
                      if (recipe != null) {
                        return recipeCard(recipe, context);
                      }
                    }
                    // Karta kolekcji z photo_url
                    final photoUrl = getPhotoUrl != null ? getPhotoUrl(item) : null;
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        // USUNIĘTO border
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: photoUrl != null && photoUrl.isNotEmpty
                                ? Image.network(
                                    '${constatns.picsBucketUrl}/$photoUrl',
                                    height: 110,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'images/default_recipe_image.jpg',
                                      height: 110,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'images/default_recipe_image.jpg',
                                    height: 110,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  getName(item),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget popularRecipes() {
    return FutureBuilder<List<Recipe>>(
      future: _popularRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No popular recipes available.');
        } else {
          final recipes = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Popular Recipes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return recipeCard(recipe, context);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}


