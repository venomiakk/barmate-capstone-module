import 'package:flutter/material.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/ingredient_repository.dart';

class UserStashScreen extends StatefulWidget {
  const UserStashScreen({super.key});

  @override
  State<UserStashScreen> createState() => _UserStashScreenState();
}

class _UserStashScreenState extends State<UserStashScreen> {
  final IngredientRepository repository = IngredientRepository();
  final List<Ingredient> stash = [];

  void _addIngredient(String ingredientId) async {
  final id = int.tryParse(ingredientId);
  if (id == null) return;

  final ingredient = await repository.fetchIngredientById(id);
  if (ingredient != null && !stash.any((i) => i.id == ingredient.id)) {
    setState(() {
      stash.add(ingredient);
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      'Your Stash',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 20),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 40,
                      ),
                      onPressed: () async {
                        final ingredientId = await _showAddIngredientDialog(context);
                        if (ingredientId != null) {
                          _addIngredient(ingredientId);
                        }
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: stash.length,
                  itemBuilder: (context, index) {
                    final ingredient = stash[index];
                    return ListTile(
                      title: Text(ingredient.name),
                      subtitle: Text('ID: ${ingredient.id.toString()}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showAddIngredientDialog(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Ingredient by ID'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter Ingredient ID"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
