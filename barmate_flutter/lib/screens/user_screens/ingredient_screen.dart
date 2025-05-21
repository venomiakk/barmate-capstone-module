import 'package:flutter/material.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/model/recipe_model.dart';

class IngredientScreen extends StatelessWidget {
  final UserStash ingredient;
  final RecipeRepository recipeRepository;
  final IngredientRepository ingredientRepository;

  IngredientScreen({
    super.key,
    required this.ingredient,
    RecipeRepository? recipeRepository,
    IngredientRepository? ingredientRepository,
  })  : recipeRepository = recipeRepository ?? RecipeRepository(),
        ingredientRepository = ingredientRepository ?? IngredientRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(ingredient.ingredientName)),
      body: FutureBuilder<Ingredient?>(
        future: ingredientRepository.fetchIngredientById(ingredient.ingredientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildBasicIngredientInfo(theme);
          }

          final fullIngredient = snapshot.data!;

          final amountWithUnit = ingredient.amount != null
              ? '${ingredient.amount} ${fullIngredient.unit ?? ''}'.trim()
              : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: fullIngredient.photo_url != null && fullIngredient.photo_url!.isNotEmpty
                        ? Image.network(
                            fullIngredient.photo_url!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/przyklad.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fullIngredient.name,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$amountWithUnit • ${ingredient.categoryName}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Divider(
                  thickness: 1,
                  color: theme.colorScheme.outline.withOpacity(.4),
                  indent: 24,
                  endIndent: 24,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Opis',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fullIngredient.description ?? 'Brak opisu składnika.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drinki zawierające ${fullIngredient.name}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder<List<Recipe>>(
                  future: recipeRepository.getRecipesByIngredient(ingredient.ingredientId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Brak drinków dla tego składnika.');
                    }

                    final drinks = snapshot.data!;

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: drinks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final drink = drinks[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              drink.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicIngredientInfo(ThemeData theme) {
    return Center(
      child: Text(
        'Brak pełnych danych dla składnika ${ingredient.ingredientName}',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
