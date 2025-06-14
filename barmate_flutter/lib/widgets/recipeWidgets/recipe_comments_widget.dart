import 'package:barmate/model/recipe_comment_model.dart';
import 'package:flutter/material.dart';
import 'package:barmate/repositories/report_repository.dart';
import 'package:barmate/repositories/comments_repository.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/widgets/recipeWidgets/add_comment_widget.dart';

class BuildCommentsListWidget extends StatefulWidget {
  final List<RecipeComment> comments;
  final bool loading;
  final int recipeId; // <-- dodaj to!
  final VoidCallback? onCommentsChanged;

  BuildCommentsListWidget({
    super.key,
    required this.comments,
    required this.loading,
    required this.recipeId,
    this.onCommentsChanged, // <-- dodaj to!
  });

  @override
  State<BuildCommentsListWidget> createState() =>
      _BuildCommentsListWidgetState();
}

class _BuildCommentsListWidgetState extends State<BuildCommentsListWidget> {
  String? userId;
  String? userLogin;
  bool _initLoading = true;
  final CommentsRepository _commentsRepository = CommentsRepository();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prefs = await UserPreferences.getInstance();
    setState(() {
      userId = prefs.getUserId();
      userLogin = prefs.getUserName();
      _initLoading = false;
    });
  }

  Future<void> _reportComment(BuildContext context, int commentId) async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in!')));
      return;
    }
    final repo = ReportRepository();
    try {
      await repo.addReport(null, commentId, userId!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comment reported!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error reporting comment: $e')));
    }
  }

  void _showAddCommentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    offset: Offset(0, 8),
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                  ),
                ],
              ),
              child: AddCommentFormWidget(
                recipeId: widget.recipeId,
                userId: userId ?? '',
                onSubmit: (
                  int p_recipe_id,
                  String p_photo_url,
                  int p_rating,
                  String p_comment,
                  String p_user_id,
                ) async {
                  // Dodaj komentarz przez CommentsRepository
                  await _commentsRepository.addCommentToRecipe(
                    p_recipe_id,
                    p_photo_url,
                    p_rating,
                    p_comment,
                    p_user_id,
                  );
                  if (mounted) setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment added!')),
                  );
                  // Usuwamy Navigator.of(context).pop(); stąd!
                },
                closeModal: () => Navigator.of(context).pop(),
                userLogin: userLogin,
                comments: widget.comments,
                onCommentAdded: () {
                  if (widget.onCommentsChanged != null) widget.onCommentsChanged!();
                  if (mounted) setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading || widget.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Sprawdź, czy użytkownik już dodał komentarz do tego przepisu
    final bool hasUserCommented = widget.comments.any(
      (c) => c.userName == userLogin,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Comments:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 12),
            // Przycisk "Add comment" pojawia się tylko jeśli użytkownik NIE dodał jeszcze komentarza
            if (userId != null && userId!.isNotEmpty && !hasUserCommented)
              ElevatedButton.icon(
                icon: const Icon(Icons.add_comment),
                label: const Text('Add comment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showAddCommentDialog,
              ),
          ],
        ),
        if (widget.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No comments yet.'),
          ),
        ...widget.comments.map(
          (c) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: StarRating(rating: c.rating, size: 20),
              title: Text(c.userName ?? 'Anonymous'),
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
          onTap:
              onRatingChanged != null
                  ? () => onRatingChanged!(index + 1)
                  : null,
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
