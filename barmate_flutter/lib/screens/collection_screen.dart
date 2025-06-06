import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/collecrion_recipe_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'user_screens/recipe_screen.dart';

class CollectionScreen extends StatefulWidget {
  final Collection collection;
  final CollectionRecipeRepository collectionRecipeRepository;

  CollectionScreen({
    super.key,
    required this.collection,
    CollectionRecipeRepository? collectionRecipeRepository,
  }) : collectionRecipeRepository = collectionRecipeRepository ?? CollectionRecipeRepository();

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = widget.collectionRecipeRepository.getRecipesByCollectionId(widget.collection.id);
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
      body: CustomScrollView(
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
                    child: (widget.collection.photoUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            '${constants.picsBucketUrl}/${widget.collection.photoUrl!}',
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/przyklad.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
            ),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: Text(
                  widget.collection.name,
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
                  buildDescription(widget.collection.description),
                  const SizedBox(height: 16),
                  Text(
                    'Drinks in this collection:',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Recipe>>(
                    future: _recipesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No drinks in this collection.');
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
                            },
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
      ),
    );
  }
}