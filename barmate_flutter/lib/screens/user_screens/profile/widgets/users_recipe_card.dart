import 'package:flutter/material.dart';
import 'package:barmate/constants.dart' as constants;

class UserRecipe {
  final int id;
  final int recipeId;
  final String name;
  final String imageUrl;
  final String? description;

  UserRecipe({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.imageUrl,
    this.description,
  });
}

class UserRecipeCard extends StatelessWidget {
  final UserRecipe recipe;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDeleteMode;
  final bool showRemoveButton; // Nowy parametr dla kontroli wyświetlania X

  const UserRecipeCard({
    super.key,
    required this.recipe,
    this.onRemove,
    this.onTap,
    this.isSelected = false,
    this.isDeleteMode = false,
    this.showRemoveButton = true, // Domyślnie true dla zalogowanego użytkownika
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const Key('user_recipe_card_container'),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected
                  ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    recipe.imageUrl.isNotEmpty
                        ? Image.network(
                          '${constants.picsBucketUrl}/${recipe.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (ctx, error, _) => Image.asset(
                                'images/unavailable-image.jpg',
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          'images/unavailable-image.jpg',
                          fit: BoxFit.cover,
                        ),
              ),
            ),

            // Recipe name overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Remove button (X) - tylko dla zalogowanego użytkownika
            if (showRemoveButton && onRemove != null && !isDeleteMode)
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

            // Selection indicator for delete mode
            if (isDeleteMode)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
