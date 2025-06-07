import 'package:barmate/constants.dart' as constants;
import 'package:barmate/model/account_model.dart';
import 'package:barmate/model/category_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/tag_model.dart';
import 'package:barmate/repositories/category_repository.dart';
import 'package:barmate/repositories/shopping_list_repository.dart';
import 'package:barmate/repositories/account_repository.dart';
import 'package:barmate/repositories/tag_repository.dart';
import 'package:barmate/screens/user_screens/ingredient_screen.dart';
import 'package:barmate/screens/user_screens/public_user_profile/public_user_profile_screen.dart';
import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:barmate/screens/user_screens/search_filter_screen.dart';
import 'package:barmate/screens/user_screens/ingredient_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter_cache/flutter_cache.dart' as cache;
import 'package:barmate/constants.dart' as constatns;

class SearchPage extends StatefulWidget {
  final bool? isFromAddRecipe;
  const SearchPage({super.key, this.isFromAddRecipe = false});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var logger = Logger(printer: PrettyPrinter());

  final IngredientRepository ingredientRepository = IngredientRepository();
  final UserStashRepository userStashRepository = UserStashRepository();
  final RecipeRepository recipeRepository = RecipeRepository();
  final ShoppingListRepository shoppingListRepository =
      ShoppingListRepository();
  final AccountRepository accountRepository = AccountRepository();
  final CategoryRepository categoryRepository = CategoryRepository();
  final TagRepository tagRepository = TagRepository();

  final List<Ingredient> ingredients = [];
  final List<Recipe> recipes = [];
  final List<Account> accounts = [];
  final List<Ingredient> filteredIngredients = [];
  final List<Recipe> filteredRecipes = [];
  final List<Account> filteredAccounts = [];
  final List<dynamic> filteredItems = [];

  final List<Map<String, bool>> filters = [];
  final List<Map<String, bool>> categories = [];
  final List<Map<String, bool>> tags = [];

  int counter = 1;
  final int minValue = 1;
  final int maxValue = 99999;

  String searchText = '';

  late final bool _isFromAddRecipe;

  @override
  void initState() {
    super.initState();
    _isFromAddRecipe = widget.isFromAddRecipe ?? false;
    if (_isFromAddRecipe) {
      _loadIngredients();
      filters.addAll([
        {'Ingredients': true},
        {'Recipes': false},
        {'Users': false},
      ]);
      _loadTags();
      _loadCategories();
    } else {
      _loadIngredients();
      _loadRecipes();
      _loadAccounts();
      filters.addAll([
        {'Ingredients': true},
        {'Recipes': true},
        {'Users': true},
      ]);
      _loadTags();
      _loadCategories();
    }
  }

  Future<Map<String, dynamic>?> _showAddToDialog(
    Ingredient ingredient,
    String destination,
  ) async {
    int counter;
    List<int> defaultValues;
    if (_isFromAddRecipe) {
      counter =
          ingredient.unit == 'ml'
              ? 50
              : ingredient.unit == 'g'
              ? 10
              : 1;

      defaultValues =
          ingredient.unit == 'ml'
              ? [10, 20, 40, 50, 60, 100]
              : ingredient.unit == 'g'
              ? [1, 2, 5, 10, 15, 20]
              : [1, 2, 3, 4, 6, 8];
    } else {
      counter =
          ingredient.unit == 'ml'
              ? 500
              : ingredient.unit == 'g'
              ? 1000
              : 1;

      defaultValues =
          ingredient.unit == 'ml'
              ? [100, 330, 500, 700, 1000, 2000]
              : ingredient.unit == 'g'
              ? [100, 200, 500, 750, 1000, 1500]
              : [1, 2, 3, 5, 10, 20];
    }

    TextEditingController controller = TextEditingController(
      text: counter.toString(),
    );

    final result = await showDialog(
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
                      width:
                          ingredient.unit == 'ml'
                              ? 350
                              : ingredient.unit == 'leaves'
                              ? 400
                              : 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Amount (${ingredient.unit})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter amount',
                            ),
                            onChanged: (value) {
                              setState(() {
                                counter = int.tryParse(value) ?? counter;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children:
                                defaultValues.map((value) {
                                  return ChoiceChip(
                                    label: Text('$value ${ingredient.unit}'),
                                    selected: counter == value,
                                    onSelected: (_) {
                                      setState(() {
                                        counter = value;
                                        controller.text = value.toString();
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (destination == 'shopping list') {
                                _addToShoppingList(ingredient.id, counter);
                                Navigator.of(context).pop();
                              } else if (destination == 'stash') {
                                _addToStash(ingredient.id, counter);
                                Navigator.of(context).pop();
                              } else if (destination == 'recipe') {
                                logger.d(
                                  'Returning ingredient: $ingredient and amount: $counter',
                                );
                                Navigator.of(context).pop({
                                  'id': ingredient.id,
                                  'ingredient': ingredient,
                                  'amount': counter,
                                });
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Add to $destination',
                              style: const TextStyle(fontSize: 16),
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
    return result;
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
          if (_isFromAddRecipe)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          Expanded(
            child: SearchBar(
              hintText: 'Search',
              onChanged: (query) {
                setState(() {
                  searchText = query;
                });
                _filterIngredients(query);
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    // Implement voice search functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SearchFilterScreen(
              filters: filters,
              categories: categories,
              tags: tags,
              isFromAddRecipe: _isFromAddRecipe,
            ),
      ),
    );
    _filterIngredients(searchText);
    logger.d('Filters $filters');
    logger.d('Categories $categories');
    logger.d('Tags $tags');
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

  Widget _buildIngredientCard(Ingredient ingredient) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => IngredientScreen(
                  ingredientId: ingredient.id,
                  isFromStash: true,
                ),
          ),
        );
      },
      child: Card(
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
      ),
    );
  }

  Stack _buildCardImage(String? photoUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              (photoUrl?.isNotEmpty ?? false)
                  ? Image.network(
                    '${constants.picsBucketUrl}/${photoUrl!}',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  )
                  : Image.asset(
                    'images/unavailable-image.jpg',
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
    if (_isFromAddRecipe) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 30),
            onPressed: () async {
              final result = await _showAddToDialog(ingredient, 'recipe');

              if (result != null) {
                Navigator.pop(context, {
                  'id': result['id'],
                  'ingredient': result['ingredient'],
                  'amount': result['amount'],
                });
              }
            },
          ),
        ],
      );
    } else {
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
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeScreen(recipe: recipe)),
        );
      },
      child: Card(
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PublicUserProfileScreen(userId: account.id.toString()),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _buildCardImage(account.avatar),
            const SizedBox(width: 16),
            _buildCardInfo(account),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
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

      if (filters[0].values.first) {
        for (final ingredient in ingredients) {
          if (ingredient.name.toLowerCase().contains(lowerQuery) &&
              categories.any(
                (category) =>
                    category.keys.first == ingredient.category &&
                    category.values.first,
              )) {
            final similarity = StringSimilarity.compareTwoStrings(
              ingredient.name.toLowerCase(),
              lowerQuery,
            );
            allMatches.add({'item': ingredient, 'similarity': similarity});
          }
        }
      }

      if (filters[1].values.first) {
        for (final recipe in recipes) {
          if ((recipe.name.toLowerCase().contains(lowerQuery) ||
                  recipe.ingredients?.any(
                        (ingredient) =>
                            ingredient.name.toLowerCase().contains(lowerQuery),
                      ) ==
                      true) &&
              tags.any(
                (tagMap) =>
                    tagMap.values.first == true &&
                    recipe.tags!.any(
                      (recipeTag) => recipeTag.name == tagMap.keys.first,
                    ),
              )) {
            final similarity = StringSimilarity.compareTwoStrings(
              recipe.name.toLowerCase(),
              lowerQuery,
            );
            allMatches.add({'item': recipe, 'similarity': similarity});
          }
        }
      }
      if (filters[2].values.first) {
        for (final account in accounts) {
          if (account.login.toLowerCase().contains(lowerQuery)) {
            final similarity = StringSimilarity.compareTwoStrings(
              account.login.toLowerCase(),
              lowerQuery,
            );
            allMatches.add({'item': account, 'similarity': similarity});
          }
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

  Future<void> _loadIngredients() async {
    final cached = await cache.load('ingredients', null);

    if (cached != null && cached is List) {
      logger.d('Loaded ingredients from cache');

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
      logger.d('Fetching ingredients from API');

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
      logger.d('Loaded recipes from cache');

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
      logger.d('Fetching recipes from API');

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
      logger.d('Loaded accounts from cache');

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
      logger.d('Fetching accounts from API');

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

  Future<void> _loadCategories() async {
    final cached = await cache.load('categories', null);

    if (cached != null && cached is List) {
      logger.d('Loaded categories from cache');

      final List<Category> cachedCategories =
          cached
              .map<Category>(
                (item) => Category.fromMap(item as Map<String, dynamic>),
              )
              .toList();

      setState(() {
        categories.addAll(cachedCategories.map((tag) => {tag.name: true}));
      });
    } else {
      logger.d('Fetching categories from API');

      final List<Category> fetchedCategories =
          await categoryRepository.getEveryCategory();

      final List<Map<String, dynamic>> categoriesMaps =
          fetchedCategories.map((i) => i.toMap()).toList();

      cache.remember('categories', categoriesMaps, 86400);
      cache.write('categories', categoriesMaps, 86400);

      setState(() {
        categories.addAll(fetchedCategories.map((tag) => {tag.name: true}));
      });
    }
  }

  Future<void> _loadTags() async {
    final cached = await cache.load('tags', null);

    if (cached != null && cached is List) {
      logger.d('Loaded tags from cache');
      final List<TagModel> cachedTags =
          cached.map<TagModel>((item) => TagModel.fromMap(item)).toList();

      setState(() {
        tags.addAll(cachedTags.map((tag) => {tag.name: true}));
      });
    } else {
      logger.d('Fetching tags from API');

      final List<TagModel> fetchedTags = await tagRepository.getEveryTag();

      final List<Map<String, dynamic>> tagMaps =
          fetchedTags.map((i) => i.toMap()).toList();

      cache.remember('tags', tagMaps, 86400);
      cache.write('tags', tagMaps, 86400);

      setState(() {
        tags.addAll(fetchedTags.map((tag) => {tag.name: true}));
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

  Future<void> _pullRefresh() async {
    await _clearCache();
    await _loadIngredients();
    await _loadRecipes();
    await _loadAccounts();
    await _loadTags();
    await _loadCategories();
  }

  Future<void> _clearCache() async {
    ingredients.clear();
    cache.destroy('ingredients');
    recipes.clear();
    cache.destroy('recipes');
    accounts.clear();
    cache.destroy('accounts');
    tags.clear();
    cache.destroy('tags');
    categories.clear();
    cache.destroy('categories');
  }
}
