class FavouriteDrink {
  final int id;
  final int recipeId;
  final String drinkName;
  final String imageUrl; // Optional field for image URL

  //TODO: Add image url
  FavouriteDrink({
    required this.id,
    required this.recipeId,
    required this.drinkName,
    required this.imageUrl, // Optional field with default value
  });

  factory FavouriteDrink.fromJson(Map<String, dynamic> json) {
    return FavouriteDrink(
      id: json['id'] as int,
      recipeId: json['recipe_id'] as int,
      drinkName: json['drink_name'] as String,
      imageUrl: json['photo_url'] as String, // Optional field
    );
  }
}
