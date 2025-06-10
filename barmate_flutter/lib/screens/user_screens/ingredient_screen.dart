import 'package:barmate/constants.dart' as constants;
import 'package:barmate/controllers/notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:provider/provider.dart';
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

    UserStash? existingItem;
    try {
      existingItem = stash.firstWhere((item) => item.ingredientId == widget.ingredientId);
    } catch (e) {
      existingItem = null;
    }
    return existingItem;
  }

 Future<void> _updateAmount(int newAmount, Ingredient ingredient) async {
  if (userId == null) return;

  final stash = await widget.stashRepository.fetchUserStash(userId);
  UserStash? existingItem;
  try {
    existingItem = stash.firstWhere((item) => item.ingredientId == widget.ingredientId);
  } catch (_) {
    existingItem = null;
  }

  if (newAmount <= 0) {
    if (existingItem != null) {
      await widget.stashRepository.removeFromStash(userId!, widget.ingredientId);
    }
  } else if (existingItem != null) {
    await widget.stashRepository.changeIngredientAmount(userId!, widget.ingredientId, newAmount);
  } else {
    await widget.stashRepository.addToStash(userId, widget.ingredientId, newAmount);
  }


  Provider.of<NotificationService>(context, listen: false).maybeNotifyLowQuantity(
    ingredientName: ingredient.name,
    amount: newAmount,
    unit: ingredient.unit ?? '',
  );

  setState(() {
    _stashFuture = _loadStash();
  });
}



  Future<void> _showAddToAmountDialog(Ingredient ingredient, int currentAmount) async {
    int counter = 0;

    List<int> defaultValues = ingredient.unit == 'ml'
        ? [100, 330, 500, 700, 1000, 2000]
        : ingredient.unit == 'g'
            ? [100, 200, 500, 750, 1000, 1500]
            : [1, 2, 3, 5, 10, 20];

    TextEditingController controller = TextEditingController(text: '0');

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
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Aktualna ilość: $currentAmount ${ingredient.unit}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Dodaj ilość (${ingredient.unit}):',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Wpisz ilość do dodania',
                            ),
                            onChanged: (value) {
                              setState(() {
                                counter = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: defaultValues.map((value) {
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
                              if (counter > 0) {
                                _updateAmount(currentAmount + counter, ingredient);
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Dodaj do schowka',
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

  Widget buildDescription(String? description) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: theme.shadowColor.withOpacity(0.2),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: (ingredient.photo_url?.isNotEmpty ?? false)
                            ? Image.network(
                                '${constants.picsBucketUrl}/${ingredient.photo_url!}',
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'images/unavailable-image.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ],
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0), // trochę paddingu, żeby nie był przy krawędzi
                  child: Material(
                    color: Colors.black.withOpacity(0.4), // szare półprzezroczyste tło
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0), // padding wokół ikony
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Center(
                    child: Text(
                      ingredient.name,
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
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildDescription(ingredient.description),
                      const SizedBox(height: 16),

                      if (userId != null && widget.isFromStash)
                        FutureBuilder<UserStash?>(
                          future: _stashFuture,
                          builder: (context, stashSnapshot) {
                            if (stashSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final stash = stashSnapshot.data;
                            final currentAmount = stash?.amount ?? 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.grey.shade100.withOpacity(0.6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.inventory_2_rounded, color: Colors.black54),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'In your stash',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$currentAmount ${ingredient.unit}',
                                              style: theme.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit amount',
                                        icon: const Icon(Icons.edit, color: Colors.black87),
                                        onPressed: () {
                                          _showEditAmountDialog(ingredient, currentAmount);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      Text(
                        'Drinks which contains: ${ingredient.name}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      FutureBuilder<List<Recipe>>(
                        future: widget.recipeRepository.getRecipesByIngredient(widget.ingredientId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No drinks which contains:');
                          }

                          final drinks = snapshot.data!;
                          return SizedBox(
                            height: 230,
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
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: (drink.photoUrl != null && drink.photoUrl!.isNotEmpty)
                                                ? Image.network(
                                                    '${constants.picsBucketUrl}/${drink.photoUrl!}',
                                                    height: 230,
                                                    width: 140,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'images/przyklad.png',
                                                    height: 230,
                                                    width: 140,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                borderRadius: const BorderRadius.vertical(
                                                  bottom: Radius.circular(15),
                                                ),
                                              ),
                                              child: Text(
                                                drink.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditAmountDialog(Ingredient ingredient, int currentAmount) async {
  int counter = currentAmount;

  List<int> defaultValues = ingredient.unit == 'ml'
      ? [100, 330, 500, 700, 1000, 2000]
      : ingredient.unit == 'g'
          ? [100, 200, 500, 750, 1000, 1500]
          : [1, 2, 3, 5, 10, 20];

  TextEditingController controller = TextEditingController(text: counter.toString());

  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set amount (${ingredient.unit}):',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'amount',
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
                      children: defaultValues.map((value) {
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
                        _updateAmount(counter, ingredient);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save to stash', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
}