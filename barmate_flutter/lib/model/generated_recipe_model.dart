import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/tag_model.dart';

class GeneratedRecipeModel {
  final String name;
  final dynamic description;
  final List<GeneratedIngredient> ingredients;
  final List<Map<String, dynamic>> steps;


  GeneratedRecipeModel({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,

  
  });

  factory GeneratedRecipeModel.fromJson(Map<String, dynamic> json) {
    return GeneratedRecipeModel(
      name: json['name'] as String,
      description: json['description'],
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((ingredient) => GeneratedIngredient.fromJson(ingredient as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((step) => step as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
    };
  }
}

class GeneratedIngredient {
  final String name;
  final String amount;
  final String unit;

  GeneratedIngredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory GeneratedIngredient.fromJson(Map<String, dynamic> json) {
    return GeneratedIngredient(
      name: json['name'] as String,
      amount: json['amount'] as String,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
}