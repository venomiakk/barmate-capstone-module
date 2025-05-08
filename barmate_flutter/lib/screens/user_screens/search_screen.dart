import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/repositories/stash_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final IngredientRepository ingredientRepository = IngredientRepository();
  final UserStashRepository userStashRepository = UserStashRepository();
  final List<Ingredient> ingredients = [];
  final List<Ingredient> filteredIngredients = [];

  void _loadIngredients() async {
    final List<Ingredient> fetchedIngredients =
        await ingredientRepository.fetchAllIngredients();
    setState(() {
      ingredients.addAll(fetchedIngredients);
      filteredIngredients.addAll(fetchedIngredients);
    });
  }

  void _addToStash(int ingredientId, int quantity) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await userStashRepository.addToStash(userId, ingredientId, quantity);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchBar(
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  hintText: 'Search',
                  onChanged: (value) {
                    // Implement search functionality here
                    // For example, filter the ingredients list based on the search query
                    setState(() {
                      filteredIngredients.clear();
                      filteredIngredients.addAll(
                        ingredients.where((ingredient) {
                          return ingredient.name.toLowerCase().contains(
                            value.toLowerCase(),
                          );
                        }),
                      );
                    });
                  },
                  leading: const Icon(Icons.search),
                  trailing: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
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
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // zamyka okno
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.count(
                  crossAxisCount: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.6,
                  children: List.generate(filteredIngredients.length, (index) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'images/przyklad.png',
                                  width: 104,
                                  height: 104,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
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
                                        Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withOpacity(0.1),
                                        Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withOpacity(0.25),
                                        Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withOpacity(0.5),
                                        Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withOpacity(0.75),
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                      ],
                                      stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  filteredIngredients[index].name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  filteredIngredients[index].description,
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, size: 30),
                                onPressed: () {
                                  int counter = 1;
                                  int minValue = 1;
                                  int maxValue = 99;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: StatefulBuilder(
                                          builder: (
                                            BuildContext context,
                                            StateSetter setState,
                                          ) {
                                            return Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    20.0,
                                                  ),
                                                  child: SizedBox(
                                                    height: 150,
                                                    width: 300,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.remove,
                                                              ),
                                                              iconSize: 32.0,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (counter >
                                                                      minValue)
                                                                    counter--;
                                                                });
                                                              },
                                                            ),
                                                            Text(
                                                              '$counter',
                                                              style: const TextStyle(
                                                                fontSize: 24.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.add,
                                                              ),
                                                              iconSize: 32.0,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (counter <
                                                                      maxValue)
                                                                    counter++;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _addToStash(
                                                              filteredIngredients[index]
                                                                  .id,
                                                              counter,
                                                            );
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      24.0,
                                                                  vertical:
                                                                      12.0,
                                                                ),
                                                          ),
                                                          child: const Text(
                                                            'Add to stash',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                            ),
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
                                                    icon: const Icon(
                                                      Icons.close,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
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
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.shopping_cart, size: 26),
                                onPressed: () {
                                  int counter = 1;
                                  int minValue = 1;
                                  int maxValue = 99;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: StatefulBuilder(
                                          builder: (
                                            BuildContext context,
                                            StateSetter setState,
                                          ) {
                                            return Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    20.0,
                                                  ),
                                                  child: SizedBox(
                                                    height: 150,
                                                    width: 300,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.remove,
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        4.0,
                                                                    horizontal:
                                                                        18.0,
                                                                  ),
                                                              iconSize: 32.0,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (counter >
                                                                      minValue)
                                                                    counter--;
                                                                });
                                                              },
                                                            ),
                                                            Text(
                                                              '$counter',
                                                              style: const TextStyle(
                                                                fontSize: 24.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.add,
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        4.0,
                                                                    horizontal:
                                                                        18.0,
                                                                  ),
                                                              iconSize: 32.0,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (counter <
                                                                      maxValue)
                                                                    counter++;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            // Tu możesz np. przekazać wartość dalej
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      24.0,
                                                                  vertical:
                                                                      12.0,
                                                                ),
                                                            child: Text(
                                                              'Add to shopping list',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
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
                                                    icon: const Icon(
                                                      Icons.close,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
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
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
