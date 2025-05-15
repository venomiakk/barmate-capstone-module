class TitleModel {
  final int id;
  final String title;

  TitleModel({required this.id, required this.title});

  // Factory constructor to create a TitleModel instance from JSON
  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(id: json['id'] as int, title: json['title'] as String);
  }
  // Method to convert a TitleModel instance to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}
