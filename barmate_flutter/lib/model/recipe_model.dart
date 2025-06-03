import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/tag_model.dart';

class Recipe {
  final int id;
  final String name;
  final dynamic description;
  final List<Ingredient>? ingredients;
  final String? photoUrl;
  final List<TagModel>? tags;
  final String? creatorId; // <--- Dodane pole

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.ingredients,
    this.photoUrl,
    this.tags,
    this.creatorId, // <--- Dodane pole
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
      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>)
              .map((tag) => TagModel.fromMap(tag))
              .toList()
          : null,
      creatorId: json['creator_id'], // <--- Dodane pole
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients?.map((ingredient) => ingredient.toJson()).toList(),
      'photo_url': photoUrl,
      'tags': tags?.map((tag) => tag.toMap()).toList(),
      'creator_id': creatorId, // <--- Dodane pole
    };
  }
}
