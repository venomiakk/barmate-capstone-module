class UserStash {
  final int ingredientId;
  final String ingredientName;
  final int amount;
  final String categoryName;
  final String photoUrl;
  final String unit;

  UserStash({
    required this.ingredientId,
    required this.ingredientName,
    required this.amount,
    required this.unit,
    required this.categoryName,
    required this.photoUrl, 
  });

  factory UserStash.fromJson(Map<String, dynamic> json) {
  return UserStash(
    ingredientId: json['ingredient_id'],
    ingredientName: json['ingredient_name'],
    amount: json['amount'],
    unit: json['unit'], 
    categoryName: json['category_name'],
    photoUrl: json['photo_url'] ?? '',
  );
}

}
