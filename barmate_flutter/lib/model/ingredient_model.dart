class Ingredient {
  final int id;
  final String name;
  final String? description;
  final String? unit;
  final String? photo_url;
  final String? category;

  Ingredient({required this.id, required this.name, this.description, this.unit, this.photo_url, this.category});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] != null
      ? json['description'] as String : null,
      unit: json['unit'] != null
      ? json['unit'] as String : null,
      photo_url: json['photo_url'] != null
      ? json['photo_url'] as String : null,
      category: json['category'] != null
      ? json['category'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit': unit,
      'photo_url': photo_url,
      'category': category,
    };
  }
}
