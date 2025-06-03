import 'package:flutter/material.dart';

class Drink {
  final int id;
  final int recipeId;
  final String name;
  final String imageUrl;
  final bool isFavorite;

  Drink({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.imageUrl,
    this.isFavorite = false,
  });
}

// Simplified drink card widget that replaces the original DrinkCardWidget
class DrinkCardWidget extends StatelessWidget {
  final Drink drink;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDeleteMode;

  const DrinkCardWidget({
    super.key,
    required this.drink,
    this.onRemove,
    this.onTap,
    this.isSelected = false,
    this.isDeleteMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8), // Smaller radius
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
              blurRadius: 2, // Smaller blur
              offset: const Offset(0, 1), // Smaller offset
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Smaller radius
                child:
                    drink.imageUrl.isNotEmpty
                        ? Image.network(
                          drink.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (ctx, error, _) => Image.asset(
                                'images/przyklad.png',
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset('images/przyklad.png', fit: BoxFit.cover),
              ),
            ),

            // Drink name overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8), // Smaller radius
                  ),
                ),
                child: Text(
                  drink.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Smaller font size
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1, // Reduced to 1 line
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Remove button (X) in top right corner
            if (onRemove != null)
              Positioned(
                top: 2, // Reduced position
                right: 2, // Reduced position
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ), // Smaller icon
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
