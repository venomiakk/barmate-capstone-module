import 'package:barmate/model/ingredient_model.dart';

class Recipe {
  final int id;
  final String name;
  final dynamic description;
  final List<Ingredient>? ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'],
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List<dynamic>)
              .map((ingredient) => Ingredient.fromJson(ingredient))
              .toList()
          : null,
    );
  }
}
