
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/tag_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/tag_repository.dart';
import 'package:barmate/widgets/app_bar.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  
}

class _HomeScreenState extends State<HomeScreen> {
   late Future<List<RecipeModel>> _featuredRecipesFuture;
   late Future<List<RecipeModel>> _popularRecipesFuture;
   late Future<List<TagModel>> _tags;
  final authService = AuthService();
  final RecipeRepository recipeRepository = RecipeRepository();
  final TagRepository tagRepository = TagRepository();

  String? selectedTag; // State to track the selected tag
   
  @override
  void initState() {
    super.initState();
    _featuredRecipesFuture = recipeRepository.getRecipesByCollectionName('featured');
    _popularRecipesFuture = recipeRepository.getRecipesByCollectionName('featured');
    _tags = tagRepository.getEveryTag();
  }
  

  void logout() async {
    try {
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
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
              featured(),
              const SizedBox(height: 30),
              tags(),
              const SizedBox(height: 30),
              popularRecipes(),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget tags() {
  return FutureBuilder<List<TagModel>>(
    future: _tags,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No tags available.');
      } else {
        final tags = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 50, // Zwiększona wysokość listy tagów
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Przewijanie poziome
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectedTag == tag.name;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0), // Większy odstęp między tagami
                    child: ChoiceChip(
                      label: Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: 16, // Większy rozmiar tekstu
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // Większe zaokrąglenie
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent // Brak obramowania dla wybranych
                              : Colors.transparent, // Brak obramowania dla niewybranych
                        ),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Większy odstęp wewnętrzny
                      onSelected: (bool selected) {
                        setState(() {
                          selectedTag = selected ? tag.name : null; // Aktualizacja wybranego tagu
                        });
                      },
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

Widget featured() {
  return FutureBuilder<List<RecipeModel>>(
    future: _featuredRecipesFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No featured recipes available.');
      } else {
        final recipes = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Featured',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
  return FutureBuilder<List<RecipeModel>>(
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          recipe.name,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
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
}
