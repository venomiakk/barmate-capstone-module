class UserStash {
  final int ingredientId;
  final String ingredientName;
  final int amount;

  UserStash({
    required this.ingredientId,
    required this.ingredientName,
    required this.amount,
  });

  factory UserStash.fromJson(Map<String, dynamic> json) {
    return UserStash(
      ingredientId: json['ingredient_id'] as int,
      ingredientName: json['ingredient_name'] as String,
      amount: json['amount'] as int,
    );
  }
}
