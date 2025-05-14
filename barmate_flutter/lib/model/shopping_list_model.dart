class ShoppingList {
  final String ingredientName;
  final int amount;
  final int ingredientId;
  ShoppingList({
    required this.ingredientId,
    required this.ingredientName,
    required this.amount,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      ingredientId: json['ingredient_id'] as int,
      ingredientName: json['ingredient_name'] as String,
      amount: json['amount'] as int,
    );
  }
}
