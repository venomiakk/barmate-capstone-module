class Ingredient {
  final int id;
  final String name;
  final String? description;

  Ingredient({required this.id, required this.name, this.description});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] != null
      ? json['description'] as String : null,
    );
  }
}
