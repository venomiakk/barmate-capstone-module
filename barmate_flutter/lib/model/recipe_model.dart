import 'package:barmate/model/ingredient_model.dart';

class Recipe {
  final int id;
  final String name;
  final dynamic description;
  final List<Ingredient>? ingredients;
  final String? photoUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.ingredients,
    this.photoUrl,
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
      photoUrl: json['photo_url'] != null
          ? json['photo_url'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients?.map((ingredient) => ingredient.toJson()).toList(),
      'photo_url': photoUrl,
    };
  }
}
