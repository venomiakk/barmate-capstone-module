import 'package:flutter/material.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<Map<String, dynamic>> shoppingList = [];
  final TextEditingController _controller = TextEditingController();
  String searchQuery = '';
  bool sortAscending = true;

  bool isSearchPanelVisible = false;
  bool isAddPanelVisible = false;

  @override
  Widget build(BuildContext context) {
    final filteredList = shoppingList
        .where((item) =>
            item['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList()
      ..sort((a, b) => sortAscending
          ? a['quantity'].compareTo(b['quantity'])
          : b['quantity'].compareTo(a['quantity']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: Icon(isAddPanelVisible ? Icons.close : Icons.add),
            tooltip: isAddPanelVisible ? 'Zamknij dodawanie' : 'Dodaj składnik',
            onPressed: () {
              setState(() {
                if (isAddPanelVisible) {
                  _controller.clear();
                }
                isAddPanelVisible = !isAddPanelVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(isSearchPanelVisible ? Icons.close : Icons.search),
            tooltip: isSearchPanelVisible ? 'Zamknij wyszukiwanie' : 'Szukaj',
            onPressed: () {
              setState(() {
                if (isSearchPanelVisible) {
                  searchQuery = '';
                }
                isSearchPanelVisible = !isSearchPanelVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
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
                hintText: 'Add ingredient',
                leading: const Icon(Icons.edit),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final name = _controller.text.trim();
                      if (name.isEmpty) return;
                      setState(() {
                        shoppingList.add({'name': name, 'quantity': 1});
                        _controller.clear();
                        isAddPanelVisible = false;
                      });
                    },
                  )
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
                hintText: 'Search ingredients',
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
            child: filteredList.isEmpty
                ? const Center(child: Text('No ingredient.'))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(item['name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    item['quantity']--;
                                    if (item['quantity'] <= 0) {
                                      shoppingList.remove(item);
                                    }
                                  });
                                },
                              ),
                              Text('${item['quantity']}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    item['quantity']++;
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
