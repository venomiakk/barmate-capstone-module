import 'package:barmate/screens/user_screens/recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/screens/user_screens/ingredient_screen.dart';
import 'package:barmate/constants.dart' as constatns;

class IngredientCardsList extends StatelessWidget {
  final List<RecipeIngredientDisplay> ingredients;
  final List<UserStash> userStash;
  final bool loading;
  final int drinkCount;
  final String userId;
  final Future<void> Function(String userId, int ingredientId, int amount) onAddToShoppingList;

  const IngredientCardsList({
    super.key,
    required this.ingredients,
    required this.userStash,
    required this.loading,
    required this.drinkCount,
    required this.userId,
    required this.onAddToShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (ingredients.isEmpty) {
      return const Text('No ingredients found.');
    }

    return Column(
      children: ingredients.map((ri) {
        final isIce = ri.ingredient.name.toLowerCase() == 'ice';
        final stash = userStash.firstWhere(
          (s) => s.ingredientId == ri.ingredient.id,
          orElse: () => UserStash(
            ingredientId: -1,
            ingredientName: '',
            amount: 0,
            categoryName: '',
            photoUrl: '',
          ),
        );
        // ICE: always treat as "in stash" and "enough"
        final inStash = isIce ? true : stash.ingredientId != -1;
        bool enoughAmount = isIce ? true : false;
        if (!isIce && inStash && ri.amount != null && stash.amount != null) {
          final requiredAmountPerDrink = double.tryParse(ri.amount!);
          final ownedAmount = double.tryParse(stash.amount.toString());
          final totalRequiredAmount = (requiredAmountPerDrink ?? 0) * drinkCount;
          if (ownedAmount != null) {
            enoughAmount = ownedAmount >= totalRequiredAmount;
          }
        } else if (isIce) {
          enoughAmount = true;
        }
        final cardColor = !inStash
            ? (isDark ? Colors.grey[800] : Colors.grey[200])
            : theme.cardColor;

        final card = Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: cardColor,
          shape: inStash
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: enoughAmount ? Colors.greenAccent : Colors.orangeAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: ListTile(
            leading: isIce
                ? Image.asset(
                    'images/ice.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : (ri.ingredient.photo_url != null
                    ? Image.network(
                        '${constatns.picsBucketUrl}/${ri.ingredient.photo_url!}',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/unavailable-image.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )),
            title: Row(
              children: [
                Text(
                  ri.ingredient.name,
                  style: TextStyle(
                    color: inStash
                        ? (enoughAmount ? Colors.green[800] : Colors.orange[800])
                        : theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    fontWeight: inStash ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (inStash)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      enoughAmount ? Icons.check_circle : Icons.error_outline,
                      color: enoughAmount ? Colors.lightGreen : Colors.orangeAccent,
                      size: 22,
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              ri.ingredient.description ?? '',
              style: TextStyle(
                color: inStash
                    ? null
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ri.amount != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      () {
                        final baseAmount = double.tryParse(ri.amount!) ?? 0;
                        final totalAmount = baseAmount * drinkCount;
                        final displayAmount = totalAmount == totalAmount.roundToDouble()
                            ? totalAmount.toStringAsFixed(0)
                            : totalAmount.toStringAsFixed(2);
                        return ri.ingredient.unit != null && ri.ingredient.unit!.isNotEmpty
                            ? '$displayAmount ${ri.ingredient.unit!}'
                            : displayAmount;
                      }(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (!inStash && !isIce)
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    tooltip: 'Add to shopping list',
                    onPressed: () async {
                      try {
                        await onAddToShoppingList(
                          userId,
                          ri.ingredient.id,
                          ((double.tryParse(ri.amount ?? '1') ?? 1) * drinkCount).round(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${ri.ingredient.name} added to shopping list!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error adding to shopping list: $e'),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );

        // ICE: do not allow navigation to ingredient screen
        if (isIce) {
          return card;
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientScreen(
                    ingredientId: ri.ingredient.id,
                    isFromStash: true,
                  ),
                ),
              );
            },
            child: card,
          );
        }
      }).toList(),
    );
  }
}