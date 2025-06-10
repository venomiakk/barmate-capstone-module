import 'package:flutter/material.dart';
import 'package:barmate/repositories/report_repository.dart';
import 'package:barmate/model/report_model.dart';
import 'package:barmate/model/recipe_comment_model.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dodaj repozytorium komentarzy
import 'package:barmate/repositories/comments_repository.dart';
import 'package:barmate/constants.dart' as constants;

class CheckReportsScreen extends StatefulWidget {
  const CheckReportsScreen({super.key});

  @override
  State<CheckReportsScreen> createState() => _CheckReportsScreenState();
}

class _CheckReportsScreenState extends State<CheckReportsScreen> {
  late Future<List<Report>> _reportsFuture;
  final CommentsRepository _commentsRepository = CommentsRepository();

  // Przechowuj pobrane komentarze w mapie: commentId -> RecipeComment
  final Map<int, RecipeComment> _commentsCache = {};

  @override
  void initState() {
    super.initState();
    _reportsFuture = ReportRepository().fetchReports();
  }

  // Funkcja pobierająca komentarz po commentId (z cache lub z bazy)
  Future<RecipeComment?> _fetchComment(int commentId) async {
    if (_commentsCache.containsKey(commentId)) {
      return _commentsCache[commentId];
    }
    final comment = await _commentsRepository.fetchCommentById(commentId);
    if (comment != null) {
      _commentsCache[commentId] = comment;
    }
    return comment;
  }

  // Funkcja wywoływana po przeciągnięciu w prawo
  void _onSwipeRight(Report report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Przeciągnięto w prawo: ${report.description}')),
    );
  }

  // Funkcja wywoływana po przeciągnięciu w lewo
  void _onSwipeLeft(Report report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Przeciągnięto w lewo: ${report.description}')),
    );
  }

  Future<void> _logoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Wylogowanie z backendu (np. Supabase)
      await Supabase.instance.client.auth.signOut();
      await UserPreferences.clearAll();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zgłoszenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logoutConfirmation(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('Brak zgłoszeń.'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Dismissible(
                  key: ValueKey(
                      '${report.commentId}_${report.recipeId}_${report.userId}_${index}'),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    child: const Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete, color: Colors.white, size: 32),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _onSwipeRight(report);
                    } else if (direction == DismissDirection.endToStart) {
                      _onSwipeLeft(report);
                    }
                    setState(() {
                      reports.removeAt(index);
                    });
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: FutureBuilder<RecipeComment?>(
                        future: report.commentId != null
                            ? _fetchComment(report.commentId!)
                            : Future.value(null),
                        builder: (context, commentSnapshot) {
                          if (commentSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final comment = commentSnapshot.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.description ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              if (comment != null) ...[
                                if (comment.userName != null)
                                  Text('Autor: ${comment.userName}'),
                                Text('Treść: ${comment.comment}'),
                                Text('Ocena: ${comment.rating}'),
                                if (comment.photoUrl != null && comment.photoUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      '${constants.picsBucketUrl}/${comment.photoUrl!}',
                                      height: 80,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
                                    ),
                                  ),
                              ] else ...[
                                Text('Brak danych o komentarzu'),
                              ],
                              if (report.recipeId != null)
                                Text('Przepis ID: ${report.recipeId}'),
                              Text('Zgłaszający: ${report.userId}'),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}