import 'package:barmate/widgets/recipeWidgets/recipe_comments_widget.dart';
import 'package:flutter/material.dart';
 // jeśli masz taki widget

class AddCommentFormWidget extends StatefulWidget {
  final int recipeId;
  final String userId;
  final Future<void> Function(
    int p_recipe_id,
    String p_photo_url,
    int p_rating,
    String p_comment,
    String p_user_id,
  ) onSubmit;
  final VoidCallback? closeModal;
  final String? userLogin;
  final List comments;
  final VoidCallback onCommentAdded;

  const AddCommentFormWidget({
    super.key,
    required this.recipeId,
    required this.userId,
    required this.onSubmit,
    this.closeModal,
    required this.userLogin,
    required this.comments,
    required this.onCommentAdded,
  });

  @override
  State<AddCommentFormWidget> createState() => _AddCommentFormWidgetState();
}

class _AddCommentFormWidgetState extends State<AddCommentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add your comment',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: theme.iconTheme.color),
                onPressed: widget.closeModal ?? () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Comment',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              filled: true,
              fillColor: theme.cardColor,
            ),
            maxLines: 3,
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter a comment' : null,
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Rating:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              StarRating(
                rating: _rating,
                onRatingChanged: (value) => setState(() => _rating = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (widget.userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in!')),
                    );
                    return;
                  }
                  final alreadyCommented = widget.comments.any(
                    (c) => c.userName == widget.userLogin,
                  );
                  if (alreadyCommented) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have already added a comment!'),
                      ),
                    );
                    return;
                  }
                  await widget.onSubmit(
                    widget.recipeId,
                    _photoUrlController.text,
                    _rating,
                    _commentController.text,
                    widget.userId,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment added!')),
                  );
                  widget.onCommentAdded();
                  _commentController.clear();
                  _photoUrlController.clear();
                  setState(() => _rating = 5);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}