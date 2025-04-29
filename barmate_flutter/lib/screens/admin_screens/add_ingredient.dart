import 'package:barmate/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class AddIngredient extends StatefulWidget {
  const AddIngredient({super.key});

  @override
  State<AddIngredient> createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: const Center(
        child: Text('Add Ingredient'),
      ),
    );
  }
}