import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/favourite_drinks_repository.dart';
import 'package:barmate/repositories/history_recipes_respository.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:flutter/material.dart';

class RecipeScreen extends StatefulWidget {
  final Recipe? _recipe;

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
  List<RecipeIngredientDisplay> _ingredients = [];
  List<RecipeComment> _comments = [];
  List<RecipeSteps> _steps = [];
  List<UserStash> _userStash = [];
  bool _loadingIngredients = true;
  bool _loadingSteps = true;
  bool _loadingComments = true;
  bool _loadingStash = true;
  String userId = '';
  bool _isFavourite = false;
  bool _isInHistory = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    _fetchIngredients();
    _fetchSteps();
    _fetchComments();
    _checkFavouriteAndHistory();
  }

  Future<void> _initializePrefs() async {
    final prefs = await UserPreferences.getInstance();
    userId = prefs.getUserId();
    setState(() {});
    _checkFavouriteAndHistory();
  }

  Future<void> _checkFavouriteAndHistory() async {
    if (widget._recipe != null && userId.isNotEmpty) {
      final fav = await _favouriteDrinkRepository.checkIfFavouriteDrinkExists(
        userId,
        widget._recipe!.id,
      );
      final hist = await _historyRepository.checkIfHisotryRecipesExists(
        userId,
        widget._recipe!.id,
      );
      setState(() {
        _isFavourite = fav;
        _isInHistory = hist;
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
                categoryName: json.categoryName
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
                  id: 0, // No id returned from your function
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
          print('Response: $response');
          for (final json in response) {
            loaded.add(
              RecipeComment(
                userName: json['login'],
                rating: json['rating'],
                comment: json['comment'],
                photoUrl: json['photo_url'],
              ),
            );
          }
        }
        setState(() {
          _comments = loaded;
          _loadingComments = false;
          print(_comments);
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
                        child:
                            widget._recipe!.photoUrl != null
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
                          ...buildIngredientCards(),
                          buildStepsList(),
                          buildCommentsList(),
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
              child: SizedBox(
                height: 48, // wysokość nagłówka, możesz dostosować
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Wyśrodkowany napis
                    Center(
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
                    // Ikony po prawej
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFavourite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.black,
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
                                        setState(() => _isFavourite = false);
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
                          IconButton(
                            icon: Icon(
                              _isInHistory
                                  ? Icons.local_bar
                                  : Icons.local_bar_outlined,
                              color: Colors.black,
                            ),
                            tooltip:
                                _isInHistory
                                    ? 'Remove from history'
                                    : 'Mark as drunk',
                            onPressed:
                                _checkingStatus
                                    ? null
                                    : () async {
                                      if (_isInHistory) {
                                        await _historyRepository
                                            .removeRecipeFromHistory(
                                              userId,
                                              widget._recipe!.id,
                                            );
                                        setState(() => _isInHistory = false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Removed from history!',
                                            ),
                                          ),
                                        );
                                      } else {
                                        await _historyRepository
                                            .addRecipesToHistory(
                                              userId,
                                              widget._recipe!.id,
                                            );
                                        setState(() => _isInHistory = true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Marked as drunk!'),
                                          ),
                                        );
                                      }
                                    },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (userId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not logged in!')),
            );
            return;
          }
          showDialog(
            context: context,
            barrierDismissible: true,
            builder:
                (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).dialogBackgroundColor, // Use theme color!
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 24,
                              offset: Offset(0, 8),
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: buildAddCommentForm(
                          recipeId: widget._recipe!.id,
                          userId: userId,
                          onSubmit: _recipeRepository.addCommentToRecipe,
                          closeModal: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
          );
        },
        label: const Text('Add comment'),
        icon: const Icon(Icons.add_comment),
      ),
    );
  }

  List<Widget> buildIngredientCards() {
    if (_loadingIngredients) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    } else if (_ingredients.isEmpty) {
      return [const Text('No ingredients found.')];
    } else {
      return _ingredients
          .map(
            (ri) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading:
                    ri.ingredient.photo_url != null
                        ? Image.network(
                          ri.ingredient.photo_url!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                        : null,
                title: Text(ri.ingredient.name),
                subtitle: Text(ri.ingredient.description ?? ''),
                trailing:
                    ri.amount != null
                        ? Text(
                          ri.ingredient.unit != null &&
                                  ri.ingredient.unit!.isNotEmpty
                              ? '${ri.amount!} ${ri.ingredient.unit!}'
                              : ri.amount!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                        : null,
              ),
            ),
          )
          .toList();
    }
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

  Widget buildAddCommentForm({
    required int recipeId,
    required String userId,
    required Future<void> Function(
      int p_recipe_id,
      String p_photo_url,
      int p_rating,
      String p_comment,
      String p_user_id,
    )
    onSubmit,
    VoidCallback? closeModal,
  }) {
    final theme = Theme.of(context);
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _commentController = TextEditingController();
    final TextEditingController _photoUrlController = TextEditingController();
    int _rating = 5;

    return StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Add your comment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: closeModal ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Comment',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a comment'
                            : null,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _photoUrlController,
                decoration: InputDecoration(
                  labelText: 'Photo URL (optional)',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Rating:', style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  StarRating(
                    rating: _rating,
                    onRatingChanged: (value) => setState(() => _rating = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (userId == null || userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not logged in!')),
                        );
                        return;
                      }
                      await onSubmit(
                        recipeId,
                        _photoUrlController.text,
                        _rating,
                        _commentController.text,
                        userId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment added!')),
                      );
                      _fetchComments();
                      _commentController.clear();
                      _photoUrlController.clear();
                      setState(() => _rating = 5);
                      if (closeModal != null) closeModal();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCommentsList() {
    print('_comments: $_comments');
    if (_loadingComments) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No comments yet.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Comments:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        ..._comments.map(
          (c) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: StarRating(rating: c.rating, size: 20),
              title: Text(c.userName),
              subtitle: Text(c.comment),
              trailing:
                  c.photoUrl != null && c.photoUrl!.isNotEmpty
                      ? Image.network(
                        c.photoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget do wyboru gwiazdek
class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final void Function(int)? onRatingChanged;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.onRatingChanged,
    this.size = 28,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating;
        return GestureDetector(
          onTap:
              onRatingChanged != null
                  ? () => onRatingChanged!(index + 1)
                  : null,
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: color,
            size: size,
          ),
        );
      }),
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

// Dodaj model komentarza
class RecipeComment {
  final String userName;
  final String comment;
  final int rating;
  final String? photoUrl;

  RecipeComment({
    required this.userName,
    required this.comment,
    required this.rating,
    this.photoUrl,
  });
}

// Przykładowa lista komentarzy (zastąp pobieraniem z repozytorium)
