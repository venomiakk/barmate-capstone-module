import 'package:flutter/material.dart';
import 'package:barmate/constants.dart' as constants;

class PublicDrink {
  final int id;
  final int recipeId;
  final String name;
  final String imageUrl;

  PublicDrink({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.imageUrl,
  });
}

class PublicDrinkCardWidget extends StatelessWidget {
  final PublicDrink drink;
  final VoidCallback? onTap;

  const PublicDrinkCardWidget({super.key, required this.drink, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
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
                    drink.imageUrl.isNotEmpty
                        ? Image.network(
                          '${constants.picsBucketUrl}/${drink.imageUrl}',
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
