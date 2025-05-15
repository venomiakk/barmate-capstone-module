import 'package:barmate/model/account_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/shopping_list_repository.dart';
import 'package:barmate/repositories/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter_cache/flutter_cache.dart' as cache;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final IngredientRepository ingredientRepository = IngredientRepository();
  final UserStashRepository userStashRepository = UserStashRepository();
  final RecipeRepository recipeRepository = RecipeRepository();
  final ShoppingListRepository shoppingListRepository = ShoppingListRepository();
  final AccountRepository accountRepository = AccountRepository();

  final List<Ingredient> ingredients = [];
  final List<Recipe> recipes = [];
  final List<Account> accounts = [];
  final List<Ingredient> filteredIngredients = [];
  final List<Recipe> filteredRecipes = [];
  final List<Account> filteredAccounts = [];
  final List<dynamic> filteredItems = [];

  int counter = 1;
  final int minValue = 1;
  final int maxValue = 99999;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _loadRecipes();
    _loadAccounts();
  }

  Future<void> _loadIngredients() async {
    final cached = await cache.load('ingredients', null);

    if (cached != null && cached is List) {
      print('Loaded ingredients from cache');

      final List<Ingredient> cachedIngredients =
          cached
              .map<Ingredient>(
                (item) => Ingredient.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      setState(() {
        ingredients.addAll(cachedIngredients);
      });
    } else {
      print('Fetching ingredients from API');

      final List<Ingredient> fetchedIngredients =
          await ingredientRepository.fetchAllIngredients();

      final List<Map<String, dynamic>> ingredientMaps =
          fetchedIngredients.map((i) => i.toJson()).toList();

      cache.remember('ingredients', ingredientMaps, 120);
      cache.write('ingredients', ingredientMaps, 120);

      setState(() {
        ingredients.addAll(fetchedIngredients);
      });
    }
  }

  Future<void> _loadRecipes() async {
    final cached = await cache.load('recipes', null);

    if (cached != null && cached is List) {
      print('Loaded recipes from cache');

      final List<Recipe> cachedRecipes =
          cached
              .map<Recipe>(
                (item) => Recipe.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      setState(() {
        recipes.addAll(cachedRecipes);
      });
    } else {
      print('Fetching recipes from API');

      final List<Recipe> fetchedRecipes =
          await recipeRepository.getAllRecipes();

      final List<Map<String, dynamic>> recipeMaps =
          fetchedRecipes.map((i) => i.toJson()).toList();

      cache.remember('recipes', recipeMaps, 120);
      cache.write('recipes', recipeMaps, 120);

      setState(() {
        recipes.addAll(fetchedRecipes);
      });
    }
  }

  Future<void> _loadAccounts() async {
    final cached = await cache.load('accounts', null);

    if (cached != null && cached is List) {
      print('Loaded accounts from cache');

      final List<Account> cachedAccounts =
          cached
              .map<Account>(
                (item) => Account.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      setState(() {
        accounts.addAll(cachedAccounts);
      });
    } else {
      print('Fetching accounts from API');

      final List<Account> fetchedAccounts =
          await accountRepository.fetchAllUsers();

      final List<Map<String, dynamic>> accountMaps =
          fetchedAccounts.map((i) => i.toJson()).toList();

      cache.remember('accounts', accountMaps, 120);
      cache.write('accounts', accountMaps, 120);

      setState(() {
        accounts.addAll(fetchedAccounts);
      });
    }
  }

  Future<void> _addToStash(int ingredientId, int quantity) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await userStashRepository.addToStash(userId, ingredientId, quantity);
    }
  }

  Future<void> _addToShoppingList(int ingredientId, int quantity) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await shoppingListRepository.addToShoppingList(
        userId,
        ingredientId,
        quantity,
      );
    }
  }

  void _filterIngredients(String query) {
    setState(() {
      filteredItems.clear();
      filteredIngredients.clear();
      filteredRecipes.clear();
      filteredAccounts.clear();

      if (query.isEmpty) return;

      final lowerQuery = query.toLowerCase();

      final allMatches = <Map<String, dynamic>>[];

      for (final ingredient in ingredients) {
        if (ingredient.name.toLowerCase().contains(lowerQuery)) {
          final similarity = StringSimilarity.compareTwoStrings(
            ingredient.name.toLowerCase(),
            lowerQuery,
          );
          allMatches.add({'item': ingredient, 'similarity': similarity});
        }
      }

      for (final recipe in recipes) {
        if (recipe.name.toLowerCase().contains(lowerQuery) ||
            recipe.ingredients?.any(
                  (ingredient) =>
                      ingredient.name.toLowerCase().contains(lowerQuery),
                ) ==
                true) {
          final similarity = StringSimilarity.compareTwoStrings(
            recipe.name.toLowerCase(),
            lowerQuery,
          );
          allMatches.add({'item': recipe, 'similarity': similarity});
        }
      }

      for (final account in accounts) {
        if (account.login.toLowerCase().contains(lowerQuery)) {
          final similarity = StringSimilarity.compareTwoStrings(
            account.login.toLowerCase(),
            lowerQuery,
          );
          allMatches.add({'item': account, 'similarity': similarity});
        }
      }

      allMatches.sort(
        (a, b) =>
            (b['similarity'] as double).compareTo(a['similarity'] as double),
      );

      filteredItems.addAll(allMatches.map((e) => e['item']));

      filteredIngredients.addAll(filteredItems.whereType<Ingredient>());
      filteredRecipes.addAll(filteredItems.whereType<Recipe>());
    });
  }

  Future<void> _showAddToDialog(
    Ingredient ingredient,
    String destination,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 140,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildCounterRow(
                            counter =
                                ingredient.unit == 'ml'
                                    ? 500
                                    : ingredient.unit == 'g'
                                    ? 1000
                                    : 1,
                            minValue,
                            maxValue,
                            setState,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (destination == 'shopping list') {
                                _addToShoppingList(ingredient.id, counter);
                              } else {
                                _addToStash(ingredient.id, counter);
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Add to ' + destination,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Row _buildCounterRow(
    int counter,
    int minValue,
    int maxValue,
    StateSetter setState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          iconSize: 32.0,
          onPressed: () {
            setState(() {
              if (this.counter > minValue) this.counter--;
            });
          },
        ),
        Text(
          '${this.counter}',
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          iconSize: 32.0,
          onPressed: () {
            setState(() {
              if (this.counter < maxValue) this.counter++;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildSearchBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              hintText: 'Search',
              onChanged: _filterIngredients,
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () => _showFilterDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: 400,
              width: 300,
              child: Center(
                child: Text(
                  'Ustawienia / informacje',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  GridView _buildGrid() {
    return GridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.6,
      children: List.generate(filteredItems.length, (index) {
        return filteredItems[index] is Ingredient
            ? _buildIngredientCard(filteredItems[index])
            : filteredItems[index] is Recipe
            ? _buildRecipeCard(filteredItems[index])
            : _buildUserCard(filteredItems[index]);
      }),
    );
  }

  Card _buildIngredientCard(Ingredient ingredient) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildCardImage(ingredient.photo_url),
          const SizedBox(width: 16),
          _buildCardInfo(ingredient),
          const SizedBox(width: 8),
          _buildIngredientActions(ingredient),
        ],
      ),
    );
  }

  Stack _buildCardImage(String? photoUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            photoUrl ?? 'images/przyklad.png',
            width: 104,
            height: 104,
            fit: BoxFit.cover,
          ),
        ),
        _buildImageGradientOverlay(),
      ],
    );
  }

  Positioned _buildImageGradientOverlay() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 40,
        height: 104,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.25),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Expanded _buildCardInfo(dynamic data) {
    var name = '';
    var description = '';
    if (data is Ingredient) {
      name = data.name.toUpperCase();
      description = data.description ?? '';
    } else if (data is Recipe) {
      name = data.name.toUpperCase();
      description = data.description ?? '';
    } else if (data is Account) {
      name = data.login;
      description = data.title ?? '';
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Column _buildIngredientActions(Ingredient ingredient) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.add, size: 30),
          onPressed: () => _showAddToDialog(ingredient, 'stash'),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart, size: 26),
          onPressed: () => _showAddToDialog(ingredient, 'shopping list'),
        ),
      ],
    );
  }

  Card _buildRecipeCard(Recipe recipe) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildCardImage(recipe.photoUrl),
          const SizedBox(width: 16),
          _buildCardInfo(recipe),
          const SizedBox(width: 8),
          _buildRecipeActions(recipe),
        ],
      ),
    );
  }

  Column _buildRecipeActions(Recipe recipe) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.local_bar, size: 30),
          onPressed: () => (),
        ),
      ],
    );
  }

  _buildUserCard(Account account) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildCardImage("images/user-picture.png"),
          const SizedBox(width: 16),
          _buildCardInfo(account),
          // const SizedBox(width: 8),
          // _buildUserActions(account),
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    _clearCache();
    _loadIngredients();
    _loadRecipes();
    _loadAccounts();
  }

  void _clearCache() {
    ingredients.clear();
    cache.destroy('ingredients');
    recipes.clear();
    cache.destroy('recipes');
    accounts.clear();
    cache.destroy('accounts');
  }
}
