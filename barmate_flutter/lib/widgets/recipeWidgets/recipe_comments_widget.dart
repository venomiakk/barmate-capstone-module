import 'package:flutter/material.dart';
import 'package:barmate/repositories/report_repository.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';

class RecipeComment {
  final int commentId; // Dodaj to pole!
  final String userName;
  final String comment;
  final int rating;
  final String? photoUrl;

  RecipeComment({
    required this.commentId,
    required this.userName,
    required this.comment,
    required this.rating,
    this.photoUrl,
  });
}

class BuildCommentsListWidget extends StatefulWidget {
  final List<RecipeComment> comments;
  final bool loading;

  BuildCommentsListWidget({
    super.key,
    required this.comments,
    required this.loading,
  });

  @override
  State<BuildCommentsListWidget> createState() => _BuildCommentsListWidgetState();
}

class _BuildCommentsListWidgetState extends State<BuildCommentsListWidget> {
  String? userId;
  bool _initLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prefs = await UserPreferences.getInstance();
    setState(() {
      userId = prefs.getUserId();
      _initLoading = false;
    });
  }

  Future<void> _reportComment(BuildContext context, int commentId) async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }
    final repo = ReportRepository();
    try {
      await repo.addReport(null, commentId, userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment reported!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading || widget.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.comments.isEmpty) {
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
        ...widget.comments.map(
          (c) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: StarRating(rating: c.rating, size: 20),
              title: Text(c.userName),
              subtitle: Text(c.comment),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (c.photoUrl != null && c.photoUrl!.isNotEmpty)
                    Image.network(
                      c.photoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  IconButton(
                    icon: const Icon(Icons.report, color: Colors.redAccent),
                    tooltip: 'Report comment',
                    onPressed: () => _reportComment(context, c.commentId),
                  ),
                ],
              ),
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