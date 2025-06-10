class RecipeComment {
  final int commentId;
  final String? userId;
  final String? userName;
  final String comment;
  final int rating;
  final String? photoUrl;

  RecipeComment({
    required this.commentId,
    this.userId,
    this.userName,
    required this.comment,
    required this.rating,
    this.photoUrl,
  });

  factory RecipeComment.fromJson(Map<String, dynamic> json) {
    return RecipeComment(
      commentId: json['comment_id'] as int,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
      comment: json['comment'] as String,
      rating: json['rating'] as int,
      photoUrl: json['photo_url'] as String?,
    );
  }
}