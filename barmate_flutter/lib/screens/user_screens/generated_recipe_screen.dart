import 'package:barmate/model/generated_recipe_model.dart';
import 'package:flutter/material.dart';

class GeneratedRecipeScreen extends StatelessWidget {
  final GeneratedRecipeModel? recipe;

  const GeneratedRecipeScreen({super.key, this.recipe});

  @override
  Widget build(BuildContext context) {
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generated Recipe')),
        body: const Center(child: Text('No recipe data')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar jak w RecipeScreen
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.black.withOpacity(0.4), // gray background like in RecipeScreen
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
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Image.asset(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                recipe!.name,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          color: Theme.of(context).shadowColor.withOpacity(0.2),
                        ),
                      ],
                    ),
                    child: Text(
                      recipe!.description?.toString() ?? 'No description available.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe!.ingredients.map((ing) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Image.asset(
                            'images/unavailable-image.jpg',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            ing.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text('${ing.amount} ${ing.unit}'),
                        ),
                      )),
                  const SizedBox(height: 16),
                  const Text(
                    'Steps:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...recipe!.steps.map((step) {
                    final nr = step['step_number'] ?? '';
                    final instr = step['instruction'] ?? '';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('$nr')),
                        title: Text(instr),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

