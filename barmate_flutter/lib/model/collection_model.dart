class Collection {
  final int id;
  final String name;
  final String description;
  final String? photoUrl; // Dodane pole

  Collection({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl, // Dodane pole
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      photoUrl: json['photo_url'] as String?, // Dodane pole
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_url': photoUrl, // Dodane pole
    };
  }
}