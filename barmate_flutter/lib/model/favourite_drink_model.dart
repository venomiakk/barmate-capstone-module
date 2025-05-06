class FavouriteDrink {
  final int id;
  final int recipeId;
  final String drinkName;

  FavouriteDrink({
    required this.id,
    required this.recipeId,
    required this.drinkName,
  });

  factory FavouriteDrink.fromJson(Map<String, dynamic> json) {
    return FavouriteDrink(
      id: json['id'] as int,
      recipeId: json['recipe_id'] as int,
      drinkName: json['drink_name'] as String,
    );
  }
}
