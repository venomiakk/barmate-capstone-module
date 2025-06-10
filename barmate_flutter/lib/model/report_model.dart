import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/tag_model.dart';

  
class Report {
  final String? description;
  final int? commentId;
  final int? recipeId;
  final String userId;

  Report({
    this.description,
    this.commentId,
    this.recipeId,
    required this.userId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      description: json['description'] as String?,
      commentId: json['comment_id'] as int?,
      recipeId: json['recipe_id'] as int?,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'comment_id': commentId,
      'recipe_id': recipeId,
      'user_id': userId,
    };
  }
}
