import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/shopping_list_model.dart';
import 'package:barmate/repositories/shopping_list_repository.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListRepository repository = ShoppingListRepository();
  final TextEditingController _controller = TextEditingController();

  List<ShoppingList> shoppingList = [];
  Set<int> checkedItems = {};
  String searchQuery = '';
  bool sortAscending = true;

  bool isSearchPanelVisible = false;
  bool isAddPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final fetchedList = await repository.fetchUserShoppingList();
    setState(() {
      shoppingList = fetchedList;
    });
  }

  Future<void> _deleteFullShoppingList() async {
    await repository.deleteFullShoppingList();
    setState(() {
      shoppingList.clear();
      checkedItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cała lista została kupiona i usunięta.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        shoppingList
            .where(
              (item) => item.ingredientName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList()
          ..sort(
            (a, b) =>
                sortAscending
                    ? a.amount.compareTo(b.amount)
                    : b.amount.compareTo(a.amount),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: Icon(isAddPanelVisible ? Icons.close : Icons.add),
            tooltip: isAddPanelVisible ? 'Zamknij dodawanie' : 'Dodaj składnik',
            onPressed: () {
              setState(() {
                if (isAddPanelVisible) _controller.clear();
                isAddPanelVisible = !isAddPanelVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(isSearchPanelVisible ? Icons.close : Icons.search),
            tooltip: isSearchPanelVisible ? 'Zamknij wyszukiwanie' : 'Szukaj',
            onPressed: () {
              setState(() {
                if (isSearchPanelVisible) searchQuery = '';
                isSearchPanelVisible = !isSearchPanelVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(
              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: 'Sortuj ilość',
            onPressed: () {
              setState(() {
                sortAscending = !sortAscending;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isAddPanelVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SearchBar(
                controller: _controller,
                hintText: 'Add ingredient (placeholder)',
                leading: const Icon(Icons.edit),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final name = _controller.text.trim();
                      if (name.isEmpty) return;
                      setState(() {
                        shoppingList.add(
                          ShoppingList(
                            ingredientId: DateTime.now().millisecondsSinceEpoch,
                            ingredientName: name,
                            amount: 1,
                          ),
                        );
                        _controller.clear();
                        isAddPanelVisible = false;
                      });
                    },
                  ),
                ],
                elevation: const MaterialStatePropertyAll(2),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),

          if (isSearchPanelVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SearchBar(
                hintText: 'Wyszukaj składnik',
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                elevation: const MaterialStatePropertyAll(2),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
          Expanded(
            child:
                filteredList.isEmpty
                    ? const Center(child: Text('Brak składników na liście.'))
                    : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Obrazek z gradientem
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'images/przyklad.png',
                                        width: 72,
                                        height: 72,
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
                                            stops: [
                                              0.0,
                                              0.2,
                                              0.4,
                                              0.6,
                                              0.8,
                                              1.0,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),

                                // Nazwa + ilość
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.ingredientName.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              checkedItems.contains(
                                                    item.ingredientId,
                                                  )
                                                  ? Colors.grey
                                                  : Colors.black,
                                          decoration:
                                              checkedItems.contains(
                                                    item.ingredientId,
                                                  )
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ilość: ${item.amount}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              checkedItems.contains(
                                                    item.ingredientId,
                                                  )
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Check toggle
                                IconButton(
                                  icon: Icon(
                                    checkedItems.contains(item.ingredientId)
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    color:
                                        checkedItems.contains(item.ingredientId)
                                            ? Colors.green
                                            : null,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (checkedItems.contains(
                                        item.ingredientId,
                                      )) {
                                        checkedItems.remove(item.ingredientId);
                                      } else {
                                        checkedItems.add(item.ingredientId);
                                      }

                                      if (checkedItems.length ==
                                          shoppingList.length) {
                                        _deleteFullShoppingList();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
