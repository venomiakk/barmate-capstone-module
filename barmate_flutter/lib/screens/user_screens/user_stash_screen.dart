import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/stash_repository.dart';

class UserStashScreen extends StatefulWidget {
  const UserStashScreen({super.key});

  @override
  State<UserStashScreen> createState() => _UserStashScreenState();
}

class _UserStashScreenState extends State<UserStashScreen> {
  final UserStashRepository repository = UserStashRepository();
  final List<UserStash> stash = [];
  final Set<int> selectedIngredientIds = {};
  final Map<int, int> selectedAmounts = {};
  bool isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _loadStash();
  }

  Future<void> _loadStash() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final fetchedStash = await repository.fetchUserStash(userId);
    setState(() {
      stash.clear();
      stash.addAll(fetchedStash);
      selectedIngredientIds.clear();
      isDeleteMode = false;
      selectedAmounts.clear();
      for (var item in fetchedStash) {
        selectedAmounts[item.ingredientId] = item.amount;
      }
    });
  }

  Future<void> _deleteSelectedIngredients() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    for (final id in selectedIngredientIds) {
      await repository.removeFromStash(userId, id);
    }

    _loadStash();
  }

  void _toggleSelection(int ingredientId) {
    setState(() {
      if (selectedIngredientIds.contains(ingredientId)) {
        selectedIngredientIds.remove(ingredientId);
      } else {
        selectedIngredientIds.add(ingredientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stash'),
        actions: [
          IconButton(
            icon: Icon(isDeleteMode ? Icons.close : Icons.delete),
            onPressed: () {
              setState(() {
                isDeleteMode = !isDeleteMode;
                selectedIngredientIds.clear();
              });
            },
          ),
          if (isDeleteMode && selectedIngredientIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _deleteSelectedIngredients,
              tooltip: 'Confirm deletion',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.6,
                ),
                itemCount: stash.length,
                itemBuilder: (context, index) {
                  final entry = stash[index];
                  final isSelected = selectedIngredientIds.contains(entry.ingredientId);
                  return GestureDetector(
                    onTap: isDeleteMode
                        ? () => _toggleSelection(entry.ingredientId)
                        : null,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 3,
                              )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Theme.of(context).cardColor,
                            ),
                            Image.asset(
                              'images/przyklad.png',
                              fit: BoxFit.cover,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                height: 160,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      entry.ingredientName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                   SizedBox(
                                  height: 28,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final userId = Supabase.instance.client.auth.currentUser?.id;
                                          if (userId == null) return;

                                          final current = selectedAmounts[entry.ingredientId] ?? 0;
                                          final updated = current - 1;

                                          if (updated <= 0) {
                                            await repository.removeFromStash(userId, entry.ingredientId);
                                            setState(() {
                                              stash.removeAt(index); // usuń z widoku
                                              selectedAmounts.remove(entry.ingredientId); // usuń z mapy
                                            });
                                          } else {
                                            await repository.changeIngredientAmount(userId, entry.ingredientId, updated);
                                            setState(() {
                                              selectedAmounts[entry.ingredientId] = updated;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(Icons.remove, size: 19, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '${selectedAmounts[entry.ingredientId] ?? 0}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final userId = Supabase.instance.client.auth.currentUser?.id;
                                          final current = selectedAmounts[entry.ingredientId] ?? 0;
                                          final updated = current + 1;
                                          setState(() {
                                            selectedAmounts[entry.ingredientId] = updated;
                                          });
                                          await repository.changeIngredientAmount(userId, entry.ingredientId, updated);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(Icons.add, size: 19, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),                  
                                  ],
                                ),
                              ),
                            ),
                            if (isDeleteMode)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
