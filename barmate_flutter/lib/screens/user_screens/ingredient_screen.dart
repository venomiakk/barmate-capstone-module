import 'package:flutter/material.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';

class IngredientScreen extends StatefulWidget {
  final int ingredientId;
  final bool isFromStash;

  final RecipeRepository recipeRepository;
  final IngredientRepository ingredientRepository;
  final UserStashRepository stashRepository;

  IngredientScreen({
    super.key,
    required this.ingredientId,
    this.isFromStash = false,
    RecipeRepository? recipeRepository,
    IngredientRepository? ingredientRepository,
    UserStashRepository? stashRepository,
  })  : recipeRepository = recipeRepository ?? RecipeRepository(),
        ingredientRepository = ingredientRepository ?? IngredientRepository(),
        stashRepository = stashRepository ?? UserStashRepository();

  @override
  State<IngredientScreen> createState() => _IngredientScreenState();
}

class _IngredientScreenState extends State<IngredientScreen> {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  late Future<Ingredient?> _ingredientFuture;
  late Future<UserStash?> _stashFuture;

  @override
  void initState() {
    super.initState();
    _ingredientFuture = widget.ingredientRepository.fetchIngredientById(widget.ingredientId);
    _stashFuture = _loadStash();
  }

  Future<UserStash?> _loadStash() async {
    if (userId == null) return null;

    final stash = await widget.stashRepository.fetchUserStash(userId);
    return stash.firstWhere(
      (item) => item.ingredientId == widget.ingredientId
    );
  }

  Future<void> _updateAmount(int newAmount) async {
    if (userId == null) return;

    if (newAmount <= 0) {
      await widget.stashRepository.removeFromStash(userId, widget.ingredientId);
    } else {
      await widget.stashRepository.changeIngredientAmount(userId, widget.ingredientId, newAmount);
    }

    setState(() {
      _stashFuture = _loadStash();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Szczegóły składnika'),
      ),
      body: FutureBuilder<Ingredient?>(
        future: _ingredientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Nie udało się pobrać danych składnika.',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          final ingredient = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: (ingredient.photo_url?.isNotEmpty ?? false)
                        ? Image.network(ingredient.photo_url!, fit: BoxFit.cover)
                        : Image.asset('images/przyklad.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  ingredient.name,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Divider(
                  thickness: 1,
                  color: theme.colorScheme.outline.withOpacity(.4),
                  indent: 24,
                  endIndent: 24,
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Opis',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ingredient.description ?? 'Brak opisu składnika.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),

                if (userId != null && widget.isFromStash)
                  FutureBuilder<UserStash?>(
                    future: _stashFuture,
                    builder: (context, stashSnapshot) {
                      if (stashSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final stash = stashSnapshot.data;
                      final currentAmount = stash?.amount ?? 0;

                      return Column(
                        children: [
                          Text('Ilość w schowku:', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: currentAmount > 0
                                    ? () => _updateAmount(currentAmount - 1)
                                    : null,
                              ),
                              Text(
                                '$currentAmount szt.',
                                style: theme.textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () => _updateAmount(currentAmount + 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drinki zawierające ${ingredient.name}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder<List<Recipe>>(
                  future: widget.recipeRepository.getRecipesByIngredient(widget.ingredientId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Brak drinków dla tego składnika.');
                    }

                    final drinks = snapshot.data!;
                    return SizedBox(
                      height: 220,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: drinks.length,
                          itemBuilder: (context, index) {
                            final drink = drinks[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeScreen(recipe: drink),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: const EdgeInsets.only(right: 12),
                                child: Container(
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: (drink.photoUrl != null && drink.photoUrl!.isNotEmpty)
                                            ? Image.network(
                                                drink.photoUrl!,
                                                height: 160,  // większe zdjęcie
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'images/przyklad.png',
                                                height: 160,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                        child: Text(
                                          drink.name,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
