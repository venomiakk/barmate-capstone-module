class UserHistoryModel {
  final DateTime consumedAt;
  final int? id;

  UserHistoryModel({required this.consumedAt, required this.id});

  factory UserHistoryModel.fromJson(Map<String, dynamic> json) {
    return UserHistoryModel(
      consumedAt: DateTime.parse(json['created_at'] as String),
      id: json['recipe_id'] != null ? json['recipe_id'] as int : null,
    );
  }
}
