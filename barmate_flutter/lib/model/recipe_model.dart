class RecipeModel {
  final int id;
  final String name;

  RecipeModel({required this.id, required this.name});

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}