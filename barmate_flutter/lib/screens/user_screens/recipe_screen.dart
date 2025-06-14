import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/constants.dart' as constatns;
import 'package:barmate/controllers/notifications_controller.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_comment_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/favourite_drinks_repository.dart';
import 'package:barmate/repositories/history_recipes_respository.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/loggedin_user_profile_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:barmate/screens/user_screens/ingredient_screen.dart';
import 'package:barmate/screens/user_screens/public_user_profile/public_user_profile_screen.dart';
import 'package:barmate/widgets/recipeWidgets/add_comment_widget.dart';
import 'package:barmate/widgets/recipeWidgets/ingredient_card_list.dart';
import 'package:barmate/widgets/recipeWidgets/recipe_comments_widget.dart';
import 'package:flutter/material.dart';
import 'package:barmate/repositories/shopping_list_repository.dart';
import 'package:provider/provider.dart';

import 'package:barmate/repositories/report_repository.dart';
import 'package:logger/logger.dart';
import 'package:barmate/repositories/public_profile_repository.dart';


class RecipeScreen extends StatefulWidget {
  final Recipe? _recipe;
  var logger = Logger(printer: PrettyPrinter());
  RecipeScreen({super.key, Recipe? recipe}) : _recipe = recipe;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final FavouriteDrinkRepository _favouriteDrinkRepository =
      FavouriteDrinkRepository();
  final DrinkHistoryRepository _historyRepository = DrinkHistoryRepository();
  final IngredientRepository _ingredientRepository = IngredientRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();
  final UserStashRepository _userStashRepository = UserStashRepository();
  final ShoppingListRepository _shoppingListRepository =
      ShoppingListRepository();
  final ReportRepository _reportRepository = ReportRepository();
  List<RecipeIngredientDisplay> _ingredients = [];
  List<RecipeComment> _comments = [];
  List<RecipeSteps> _steps = [];
  List<UserStash> _userStash = [];
  bool _loadingIngredients = true;
  bool _loadingSteps = true;
  bool _loadingComments = true;
  bool _loadingStash = true;
  String userId = '';
  String userLogin = '';
  bool _isFavourite = false;
  bool _checkingStatus = true;
  int _drinkCount = 1; // Domyślna liczba drinków
  int? _creatorProfileId;
  String? _creatorLogin;
  String? _creatorPhotoUrl;
  bool _canReportRecipe = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    _fetchIngredients();
    _fetchSteps();
    _fetchComments();
    _checkFavouriteAndHistory();
    _fetchCreatorData(); // This will set _canReportRecipe
  }


  Future<void> _initializePrefs() async {
    final prefs = await UserPreferences.getInstance();
    userId = prefs.getUserId();
    userLogin = prefs.getUserName(); // Dodaj pobieranie loginu
    setState(() {});
    _checkFavouriteAndHistory();
    _fetchUserStash();
  }

  Future<void> _checkFavouriteAndHistory() async {
    if (widget._recipe != null && userId.isNotEmpty) {
      final fav = await _favouriteDrinkRepository.checkIfFavouriteDrinkExists(
        userId,
        widget._recipe!.id,
      );
      setState(() {
        _isFavourite = fav;
        _checkingStatus = false;
      });
    }
  }

  Future<void> _fetchUserStash() async {
    if (widget._recipe != null) {
      try {
        final response = await _userStashRepository.fetchUserStash(userId);
        final List<UserStash> loaded = [];
        if (response != null) {
          for (final json in response) {
            loaded.add(
              UserStash(
                ingredientId: json.ingredientId,
                ingredientName: json.ingredientName,
                amount: json.amount,
                unit: json.unit, // Optional field
                categoryName: json.categoryName,
                photoUrl: json.photoUrl, // Optional field
              ),
            );
          }
        }
        setState(() {
          _userStash = loaded;
          _loadingStash = false;
        });
      } catch (e) {
        setState(() {
          _userStash = [];
          _loadingStash = false;
        });
      }
    } else {
      setState(() {
        _userStash = [];
        _loadingStash = false;
      });
    }
  }

  Future<void> _fetchIngredients() async {
    if (widget._recipe != null) {
      try {
        final response = await _ingredientRepository.fetchIngriedientByRecipeId(
          widget._recipe!.id,
        );
        final List<RecipeIngredientDisplay> loaded = [];
        if (response != null) {
          for (final json in response) {
            loaded.add(
              RecipeIngredientDisplay(
                ingredient: Ingredient(
                  id: json['id'], // No id returned from your function
                  name: json['name'] ?? '',
                  description: json['decription'], // typo matches your function
                  photo_url: json['photo_url'],
                  unit: json['unit'],
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

  Future<void> _fetchSteps() async {
    if (widget._recipe != null) {
      try {
        final response = await _recipeRepository.fetchRecipeStepsByRecipeId(
          widget._recipe!.id,
        );
        final List<RecipeSteps> loaded = [];
        if (response != null) {
          for (final json in response) {
            loaded.add(
              RecipeSteps(
                description: json['description'],
                order: json['order'],
              ),
            );
          }
        }
        setState(() {
          _steps = loaded;
          _loadingSteps = false;
        });
      } catch (e) {
        setState(() {
          _ingredients = [];
          _loadingSteps = false;
        });
      }
    } else {
      setState(() {
        _ingredients = [];
        _loadingSteps = false;
      });
    }
  }

  Future<void> _fetchComments() async {
    if (widget._recipe != null) {
      try {
        final response = await _recipeRepository.fetchCommentsByRecipeId(
          widget._recipe!.id,
        );
        final List<RecipeComment> loaded = [];
        if (response != null) {
          for (final json in response) {
            loaded.add(
              RecipeComment(
                recipeId: widget._recipe!.id,
                userName: json['login'],
                rating: json['rating'],
                comment: json['comment'],
                photoUrl: json['photo_url'],
                commentId: json['id'], // Dodajemy ID komentarza
              ),
            );
          }
        }
        setState(() {
          _comments = loaded;
          _loadingComments = false;
        });
      } catch (e) {
        setState(() {
          _comments = [];
          _loadingComments = false;
        });
      }
    } else {
      setState(() {
        _comments = [];
        _loadingComments = false;
      });
    }
  }
Future<void> _removeIngredientsFromStash() async {
  try {
    for (final ri in _ingredients) {
      final stash = _userStash.firstWhere(
        (s) => s.ingredientId == ri.ingredient.id,
        orElse: () => UserStash(
          ingredientId: -1,
          ingredientName: '',
          amount: 0,
          unit: '',
          categoryName: '',
          photoUrl: '',
        ),
      );

      if (stash.ingredientId != -1 && ri.amount != null) {
        final baseAmount = double.tryParse(ri.amount!) ?? 0;
        final totalAmount = baseAmount * _drinkCount;
        final ownedAmount = stash.amount ?? 0;
        final toRemove = ownedAmount >= totalAmount ? totalAmount : ownedAmount;
        final newAmount = ownedAmount - toRemove;

        if (toRemove > 0) {
          if (newAmount <= 0) {
            await _userStashRepository.removeFromStash(
              userId,
              ri.ingredient.id,
              context: context,
              ingredientName: ri.ingredient.name,
              unit: ri.ingredient.unit ?? '',
            );
          } else {
            await _userStashRepository.changeIngredientAmount(
              userId,
              ri.ingredient.id,
              newAmount.round(),
              context: context,
              ingredientName: ri.ingredient.name,
              unit: ri.ingredient.unit ?? '',
            );
          }
        }
      }
    }

    await _fetchUserStash();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ingredients removed from stash!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error removing ingredients: $e')),
    );
  }
}



  Future<void> _fetchCreatorData() async {
    final creatorUuid = widget._recipe?.creatorId;
    if (creatorUuid == null) {
      setState(() {
        _creatorLogin = "Administrator";
        _creatorPhotoUrl = null;
        _canReportRecipe = false;
        _creatorProfileId = null;
      });
      return;
    }
    try {
      final publicProfileRepo = PublicProfileRepository();
      // Użyj fetchUserDataByUuid, żeby pobrać profil po uuid
      final profile = await publicProfileRepo.fetchUserDataByUuid(creatorUuid);
      setState(() {
        _creatorLogin = profile.username;
        _creatorPhotoUrl = profile.avatarUrl;
        _canReportRecipe = true;
        _creatorProfileId = profile.id; // int id z PublicProfileModel
      });
    } catch (e) {
      setState(() {
        _creatorLogin = "Unknown";
        _creatorPhotoUrl = null;
        _canReportRecipe = false;
        _creatorProfileId = null;
      });
    }
  }

  double get _averageRating {
    if (_comments.isEmpty) return 0.0;
    final sum = _comments.fold<int>(0, (acc, c) => acc + c.rating);
    return sum / _comments.length;
  }

  int get _commentsCount => _comments.length;

  // Dodaj funkcję do zgłaszania przepisu
  Future<void> _reportRecipe() async {
    try {
      await _reportRepository.addReport(widget._recipe!.id, null, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe has been reported!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while reporting recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget._recipe != null
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 400.0,
                      pinned: true,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Colors.black.withOpacity(0.4),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        if (_canReportRecipe)
                          IconButton(
                            icon: const Icon(Icons.report, color: Colors.redAccent, size: 32),
                            tooltip: 'Report recipe',
                            onPressed: _reportRecipe,
                          ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              child: widget._recipe!.photoUrl != null
                                  ? Image.network(
                                      '${constatns.picsBucketUrl}/${widget._recipe!.photoUrl!}',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'images/default_recipe_image.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            // Gwiazdki i liczba opinii w prawym dolnym rogu
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StarRating(
                                      rating: _averageRating.round(),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${_commentsCount})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: GestureDetector(
                                onTap: () {
                                  if (_creatorProfileId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PublicUserProfileScreen(
                                          userId: _creatorProfileId.toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Row(
                                      children: [
                                        _creatorPhotoUrl != null && _creatorPhotoUrl!.isNotEmpty
                                            ? CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage(
                                                  '${constatns.picsBucketUrl}/${_creatorPhotoUrl}',
                                                ),
                                              )
                                            : const CircleAvatar(
                                                radius: 16,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                ),
                                                backgroundColor: Colors.grey,
                                              ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _creatorLogin ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 8,
                                                color: Colors.black54,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: null,
                        centerTitle: true,
                      ),
                    ),
                    // DODAJEMY TU nowy SliverToBoxAdapter z nazwą drinka i przyciskami
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Nazwa drinka
                            Expanded(
                              child: Text(
                                widget._recipe?.name ?? '',
                                style: const TextStyle(
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
                              ),
                            ),
                            // Ikony po prawej
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primary, // kolor z theme
                                ),
                                  tooltip:
                                    _isFavourite
                                        ? 'Remove from favorites'
                                        : 'Add to favorites',
                                  onPressed:
                                    _checkingStatus
                                        ? null
                                        : () async {
                                          if (_isFavourite) {
                                            await _favouriteDrinkRepository
                                                .removeFavouriteDrink(
                                                  userId,
                                                  widget._recipe!.id,
                                                );
                                            setState(
                                              () => _isFavourite = false,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Removed from favorites!',
                                                ),
                                              ),
                                            );
                                          } else {
                                            await _favouriteDrinkRepository
                                                .addFavouriteDrink(
                                                  userId,
                                                  widget._recipe!.id,
                                                );
                                            setState(() => _isFavourite = true);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Added to favorites!',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ...description, ingredients, steps, comments...
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            buildDescription(widget._recipe!.description),
                            SizedBox(height: 16),
                            const Text(
                              'Ingredients:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'How many drinks?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed:
                                    _drinkCount > 1
                                        ? () => setState(() => _drinkCount--)
                                        : null,
                                ),
                                Text(
                                  '$_drinkCount',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() => _drinkCount++),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            IngredientCardsList(
                              ingredients: [
                                ..._ingredients,
                                if (widget._recipe!.ice == true)
                                  RecipeIngredientDisplay(
                                    ingredient: Ingredient(
                                      id: -999, // special id for ice
                                      name: 'Ice',
                                      description: 'Ice cubes',
                                      photo_url: null,
                                      unit: null,
                                      category: null,
                                    ),
                                    amount: null, // no amount for ice
                                  ),
                              ],
                              userStash: _userStash,
                              loading: _loadingIngredients,
                              drinkCount: _drinkCount,
                              userId: userId,
                              onAddToShoppingList:
                                _shoppingListRepository.addToShoppingList,
                            ),
                            // --- ICE LOGIC END ---
                            buildStepsList(),
                            buildIMadeADrinkButton(), // <-- pod stepami
                            const SizedBox(height: 16),
                            BuildCommentsListWidget(
                              comments: _comments,
                              loading: _loadingComments,
                              recipeId: widget._recipe!.id, // <-- dodaj to!
                              onCommentsChanged: _fetchComments, // <-- dodaj to!
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: Text('Recipe not found')),
        ],
      ),
    );
  }

  Widget buildDescription(String? description) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor, // Use theme color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: theme.shadowColor.withOpacity(0.2), // Use theme shadow
          ),
        ],
      ),
      child: Text(
        description ?? 'No description available.',
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget buildStepsList() {
    if (_loadingSteps) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_steps.isEmpty) {
      return const Text('No steps found.');
    } else {
      // Sortowanie po kolejności jeśli potrzebne
      final sortedSteps = List<RecipeSteps>.from(_steps)
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Steps:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ...sortedSteps.map(
            (step) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(child: Text('${step.order ?? ''}')),
                title: Text(step.description ?? ''),
              ),
            ),
          ),
        ],
      );
    }
  }

  // 1. "Add comment" obok napisu "Comments:"

  // 2. "I made a drink" pod stepami
  Widget buildIMadeADrinkButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('I made a drink'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: userId.isEmpty
              ? null
              : () async {
                  await _removeIngredientsFromStash();
                  for (int i = 0; i < _drinkCount; i++) {
                    await _historyRepository.addRecipesToHistory(
                      userId,
                      widget._recipe!.id,
                    );
                  }
                },
        ),
      ),
    );
  }
}

class RecipeIngredientDisplay {
  final Ingredient ingredient;
  final String? amount;

  RecipeIngredientDisplay({required this.ingredient, this.amount});
}

class RecipeSteps {
  final String? description;
  final int? order;

  RecipeSteps({required this.description, this.order});
}
