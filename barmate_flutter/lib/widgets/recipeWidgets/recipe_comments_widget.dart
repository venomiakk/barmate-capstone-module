import 'package:flutter/material.dart';

class RecipeComment {
  final String userName;
  final String comment;
  final int rating;
  final String? photoUrl;

  RecipeComment({
    required this.userName,
    required this.comment,
    required this.rating,
    this.photoUrl,
  });
}

class BuildCommentsListWidget extends StatelessWidget {
  List<RecipeComment> comments;
  bool loading;

  BuildCommentsListWidget({
    super.key,
    required this.comments,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No comments yet.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Comments:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        ...comments.map(
          (c) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: StarRating(rating: c.rating, size: 20),
              title: Text(c.userName),
              subtitle: Text(c.comment),
              trailing: c.photoUrl != null && c.photoUrl!.isNotEmpty
                  ? Image.network(
                      c.photoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// Możesz przenieść ten widget do osobnego pliku jeśli już go masz
class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final void Function(int)? onRatingChanged;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.onRatingChanged,
    this.size = 28,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating;
        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(index + 1) : null,
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}