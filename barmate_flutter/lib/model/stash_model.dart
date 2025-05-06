class UserStash {
  final String ingredientName;
  final int amount;

  UserStash({
    required this.ingredientName,
    required this.amount,
  });

  factory UserStash.fromJson(Map<String, dynamic> json) {
    return UserStash(
      ingredientName: json['ingredient_name'] as String,
      amount: json['amount'] as int,
    );
  }
}
