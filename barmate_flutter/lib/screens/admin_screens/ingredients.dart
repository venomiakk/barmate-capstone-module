import 'package:barmate/constants.dart' as constants;
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/collection_repository.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/screens/admin_screens/create_collection.dart';
import 'package:barmate/screens/admin_screens/create_ingredient.dart';
import 'package:barmate/screens/user_screens/collection_screen.dart';
import 'package:barmate/screens/user_screens/ingredient_screen.dart';
import 'package:barmate/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_cache/flutter_cache.dart' as cache;

class Ingredients extends StatefulWidget {
  const Ingredients({super.key});

  @override
  State<Ingredients> createState() => _AddIngredientState();
}

class _AddIngredientState extends State<Ingredients> {
  var logger = Logger(printer: PrettyPrinter());

  IngredientRepository ingredientRepository = IngredientRepository();

  List<Ingredient> ingredients = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _loadIngredients(false);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Ingredients')),
    body: Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildGrid(),
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateIngredient()),
        );
        await _loadIngredients(true);
      },
      child: const Icon(Icons.add),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
  );
}

  GridView _buildGrid() {
    return GridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.6,
      children: List.generate(ingredients.length, (index) {
        return _buildCard(ingredients[index]);
      }),
    );
  }

  Widget _buildCard(ingredient) {
    return InkWell(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => IngredientScreen(
                    ingredientId: ingredient.id,
                    isFromStash: false,
                  ),
            ),
          );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _buildImage(ingredient.photo_url),
            const SizedBox(width: 16),
            _buildInfo(ingredient),
            const SizedBox(width: 8),
            //_buildActions(ingredient),
          ],
        ),
      ),
    );
  }

   _buildImage(imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              (imageUrl?.isNotEmpty ?? false)
                  ? Image.network(
                    '${constants.picsBucketUrl}/${imageUrl!}',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  )
                  : Image.asset(
                    'images/unavailable-image.jpg',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  ),
        ),
        _buildImageGradientOverlay(),
      ],
    );
   }
  
  _buildInfo(ingredient) {
    var name = ingredient.name ?? 'No Name';
    var description = ingredient.description ?? 'No Description';
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  _buildActions(ingredient) {
  }

  Positioned _buildImageGradientOverlay() {
    return Positioned(
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
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.25),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
  
  Future<void> _loadIngredients(bool reload) async {
  final cached = await cache.load('ingredients', null);

    if (cached != null && cached is List && !reload) {
      logger.d('Loaded ingredients from cache');

      final List<Ingredient> cachedIngredients =
          cached
              .map<Ingredient>(
                (item) => Ingredient.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      if (!mounted) return;
      setState(() {
        ingredients.addAll(cachedIngredients);
      });
    } else {
      logger.d('Fetching ingredients from API');

      final List<Ingredient> fetchedIngredients =
          await ingredientRepository.fetchAllIngredients();

      final List<Map<String, dynamic>> ingredientMaps =
          fetchedIngredients.map((i) => i.toJson()).toList();

      cache.remember('ingredients', ingredientMaps, 3600);
      cache.write('ingredients', ingredientMaps, 3600);

      if (!mounted) return;
      setState(() {
        ingredients.addAll(fetchedIngredients);
      });
    }
}

}