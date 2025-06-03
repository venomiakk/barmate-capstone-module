import 'package:barmate/controllers/public_profile_controller.dart';
import 'package:barmate/screens/user_screens/public_user_profile/widgets/public_drink_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PublicFavouriteDrinksWidget extends StatefulWidget {
  final String userId;
  final String userUuid;

  const PublicFavouriteDrinksWidget({
    super.key,
    required this.userId,
    required this.userUuid,
  });

  @override
  State<PublicFavouriteDrinksWidget> createState() =>
      _PublicFavouriteDrinksWidgetState();
}

class _PublicFavouriteDrinksWidgetState
    extends State<PublicFavouriteDrinksWidget> {
  var logger = Logger(printer: PrettyPrinter());
  final PublicUserProfileController _controller =
      PublicUserProfileController.create();
  final List<PublicDrink> favoriteDrinks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteDrinks();
  }

  Future<void> _loadFavoriteDrinks() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      // Load favorite drinks from controller
      final drinks = await _controller.getUserFavoriteDrinks(widget.userUuid);
      // Convert to PublicDrink objects
      final publicDrinks =
          drinks
              .map(
                (drink) => PublicDrink(
                  id: drink['id'],
                  recipeId: drink['recipeId'],
                  name: drink['name'],
                  imageUrl: drink['imageUrl'],
                ),
              )
              .toList();

      setState(() {
        favoriteDrinks.clear();
        favoriteDrinks.addAll(publicDrinks);
        isLoading = false;
      });
    } catch (e) {
      logger.e("Error loading favorite drinks: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Couldn't load favorite drinks";
      });
    }
  }

  void viewDrinkDetails(PublicDrink drink) {
    // TODO: Navigate to drink details screen
    logger.w('TODO: Navigate to drink details for ${drink.recipeId}');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => DrinkDetailsScreen(drinkId: drink.id)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[400], size: 28),
              const SizedBox(height: 8),
              Text(errorMessage!, style: TextStyle(color: Colors.grey[600])),
              TextButton(
                onPressed: _loadFavoriteDrinks,
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    if (favoriteDrinks.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_bar_outlined, size: 36, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'This user has no favorite drinks yet',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Horizontal list of favorite drinks
    return SizedBox(
      height: 150, // Fixed height for the list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favoriteDrinks.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final drink = favoriteDrinks[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 120,
              child: PublicDrinkCardWidget(
                drink: drink,
                onTap: () => viewDrinkDetails(drink),
              ),
            ),
          );
        },
      ),
    );
  }
}
