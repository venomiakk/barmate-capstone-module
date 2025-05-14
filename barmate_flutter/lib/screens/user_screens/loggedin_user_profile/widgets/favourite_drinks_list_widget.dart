import 'package:flutter/material.dart';

class FavouriteDrinksListWidget extends StatefulWidget {
  const FavouriteDrinksListWidget({super.key});

  @override
  FavouriteDrinksListWidgetState createState() =>
      FavouriteDrinksListWidgetState();
}

class FavouriteDrinksListWidgetState extends State<FavouriteDrinksListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Text('Favourite Drinks List Content'),
        // Placeholder for the favourite drinks list content
        // You can replace this with your actual implementation
      ),
    );
  }
}
