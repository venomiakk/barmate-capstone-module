import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:flutter/material.dart';

class RecipeScreen extends StatefulWidget {
  final Recipe? _recipe;
  final ingredients = new List<Ingredient>.empty(growable: true);

  RecipeScreen({super.key, Recipe? recipe}) : _recipe = recipe;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final IngredientRepository _ingredientRepository = IngredientRepository();
  List<RecipeIngredientDisplay> _ingredients = [];
  bool _loadingIngredients = true;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    if (widget._recipe != null) {
      try {
        final response = await _ingredientRepository.fetchIngriedientByRecipeId(widget._recipe!.id);
        final List<RecipeIngredientDisplay> loaded = [];
        if (response != null) {
          for (final json in response) {
            loaded.add(
              RecipeIngredientDisplay(
                ingredient: Ingredient(
                  id: 0, // No id returned from your function
                  name: json['name'] ?? '',
                  description: json['decription'], // typo matches your function
                  photo_url: json['photo_url'],
                  unit: null,
                  category: null,
                ),
                amount: json['amont']?.toString(), // typo matches your function
              ),
            );
          }
        }
        setState(() {
          _ingredients = loaded;
          _loadingIngredients = false;
        });
      } catch (e) {
        setState(() {
          _ingredients = [];
          _loadingIngredients = false;
        });
      }
    } else {
      setState(() {
        _ingredients = [];
        _loadingIngredients = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cała zawartość scrollowana
          widget._recipe != null
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 400.0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          child: widget._recipe!.photoUrl != null
                              ? Image.network(
                                  widget._recipe!.photoUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'images/default_recipe_image.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: null,
                        centerTitle: true,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            const Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            buildDescription(widget._recipe!.description),
                            SizedBox(height: 16),
                            const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ...buildIngredientCards(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: Text('Recipe not found')),
          SafeArea(
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                widget._recipe?.name ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildIngredientCards() {
    if (_loadingIngredients) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        )
      ];
    } else if (_ingredients.isEmpty) {
      return [
        const Text('No ingredients found.')
      ];
    } else {
      return _ingredients.map((ri) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: ri.ingredient.photo_url != null
              ? Image.network(ri.ingredient.photo_url!, width: 40, height: 40, fit: BoxFit.cover)
              : null,
          title: Text(ri.ingredient.name),
          subtitle: Text(ri.ingredient.description ?? ''),
          trailing: ri.amount != null
              ? Text(ri.amount!)
              : null,
        ),
      )).toList();
    }
  }

  Widget buildDescription(String? description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        description ?? 'No description available.',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class RecipeIngredientDisplay {
  final Ingredient ingredient;
  final String? amount;

  RecipeIngredientDisplay({required this.ingredient, this.amount});
}
