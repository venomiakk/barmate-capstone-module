class TagModel {
  final int id;
  final String name;

  TagModel({required this.id, required this.name});

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}