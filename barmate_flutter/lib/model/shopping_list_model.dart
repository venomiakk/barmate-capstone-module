class ShoppingList {
  final String ingredientName;
  final int amount;
  final int ingredientId;
  final String? photoUrl; // Optional field for photo URL
  final String? unit; // Optional field for unit

  ShoppingList({
    required this.ingredientId,
    required this.ingredientName,
    required this.amount,
    this.photoUrl, // Optional field for photo URL
    this.unit, // Optional field for unit
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      ingredientId: json['ingredient_id'] as int,
      ingredientName: json['ingredient_name'] as String,
      amount: json['amount'] as int,
      unit: json['unit'] as String? ?? '', // Optional field for unit
      photoUrl:
          json['photo_url'] as String? ?? '', // Optional field for photo URL
    );
  }
}
