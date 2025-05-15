import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/drink_card_widget.dart';
import 'package:logger/logger.dart';
import 'package:barmate/model/favourite_drink_model.dart';

class FavouriteDrinksListWidget extends StatefulWidget {
  final List<FavouriteDrink>? initialDrinks;

  const FavouriteDrinksListWidget({super.key, this.initialDrinks});

  @override
  FavouriteDrinksListWidgetState createState() =>
      FavouriteDrinksListWidgetState();
}

class FavouriteDrinksListWidgetState extends State<FavouriteDrinksListWidget> {
  var logger = Logger(printer: PrettyPrinter());
  final LoggedinUserProfileController _controller =
      LoggedinUserProfileController.create();
  final List<Drink> favoriteDrinks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialDrinks != null && widget.initialDrinks!.isNotEmpty) {
      _convertAndSetDrinks();
    }
  }

  void _convertAndSetDrinks() {
    // Convert FavouriteDrink objects to Drink objects
    final drinks =
        widget.initialDrinks!
            .map(
              (favDrink) => Drink(
                id: favDrink.id,
                name: favDrink.drinkName, // Use name with fallback
                imageUrl:
                    'https://hips.hearstapps.com/hmg-prod/images/drinks-to-avoid-1621959532.jpg', // Use imageUrl properly
                isFavorite: true,
              ),
            )
            .toList();

    setState(() {
      favoriteDrinks.clear();
      favoriteDrinks.addAll(drinks);
      isLoading = false;
    });
  }

  // Update this method to check if we need to refresh when props change
  @override
  void didUpdateWidget(FavouriteDrinksListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the initial drinks list changes, update our internal list
    if (widget.initialDrinks != oldWidget.initialDrinks &&
        widget.initialDrinks != null &&
        widget.initialDrinks!.isNotEmpty) {
      _convertAndSetDrinks();
    }
  }

  void removeDrink(int drinkId) async {
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove from Favorites'),
            content: const Text(
              'Are you sure you want to remove this drink from favorites?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('REMOVE'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _controller.removeDrink(drinkId);
      } catch (e) {
        logger.w("Error removing drink from favorites: $e");
      }
      final index = favoriteDrinks.indexWhere((drink) => drink.id == drinkId);
      if (index != -1) {
        // Example of removing a drink from favorites:
        setState(() {
          favoriteDrinks.removeAt(index);
        });
        // Call API to update favorites
      }
    }
  }

  void viewDrinkDetails(Drink drink) {
    // TODO: Navigate to drink details screen
    logger.w('TODO: Navigate to drink details screen for ${drink.name}');
    // Example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => DrinkDetailsScreen(drink: drink)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoriteDrinks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the column more compact
          children: [
            Icon(Icons.local_bar_outlined, size: 24), // Smaller icon
            const SizedBox(height: 8), // Reduced spacing
            Text('No favorite drinks yet', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 4), // Reduced spacing
            TextButton(
              onPressed: () {
                // TODO: Navigate to drink discovery screen
                logger.w('TODO: Navigate to drink discovery screen');
              },
              child: const Text('Discover Drinks'),
            ),
          ],
        ),
      );
    }

    // Horizontal list view with smaller cards
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ), // Reduced padding
      scrollDirection: Axis.horizontal,
      itemCount: favoriteDrinks.length,
      itemBuilder: (context, index) {
        final drink = favoriteDrinks[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8), // Reduced padding
          child: SizedBox(
            width: 120, // Reduced width from 160px to 120px
            height: 150, // Fixed height
            child: DrinkCardWidget(
              drink: drink,
              onRemove: () => removeDrink(drink.id),
              onTap: () => viewDrinkDetails(drink),
            ),
          ),
        );
      },
    );
  }
}
