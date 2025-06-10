import 'package:flutter/material.dart';
import 'package:barmate/repositories/report_repository.dart';
import 'package:barmate/repositories/comments_repository.dart';
import 'package:barmate/model/report_model.dart';
import 'package:barmate/model/recipe_comment_model.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/constants.dart' as constants;
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/model/recipe_model.dart';

class CheckReportsScreen extends StatefulWidget {
  const CheckReportsScreen({super.key});

  @override
  State<CheckReportsScreen> createState() => _CheckReportsScreenState();
}

class _CheckReportsScreenState extends State<CheckReportsScreen> {
  late Future<List<Report>> _reportsFuture;
  final CommentsRepository _commentsRepository = CommentsRepository();
  final ReportRepository _reportRepository = ReportRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();

  final Map<int, RecipeComment> _commentsCache = {};
  final Map<int, Recipe> _recipesCache = {};
  final Map<int, List<Map<String, dynamic>>> _stepsCache = {};

  @override
  void initState() {
    super.initState();
    _reportsFuture = _reportRepository.fetchReports();
  }

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

  // Removes the report and related comment or recipe
  Future<void> _removeReportAndContent(Report report, {Recipe? recipe}) async {
    bool success = true;

    // First, remove the report
    final reportResult = await _reportRepository.removeReport(report.id);
    if (reportResult == null) success = false;

    // Then remove the comment (if applicable)
    if (success && report.commentId != null) {
      final commentResult = await _commentsRepository.removeComment(report.commentId!);
      if (commentResult == null) success = false;
    }

    // Then remove the recipe (if applicable and allowed)
    if (success && report.recipeId != null && recipe != null) {
      if (recipe.creatorId == null) {
        // Recipe is admin's, do not allow removal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This is an admin recipe and cannot be removed."),
          ),
        );
        return;
      } else {
        // Remove the recipe (call your repository method)
        await _recipeRepository.deleteRecipe(recipe.id, recipe.photoUrl!);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Report and related content have been removed.'
            : 'An error occurred while removing.'),
      ),
    );
    setState(() {
      _reportsFuture = _reportRepository.fetchReports();
    });
  }

  // Usuwa tylko zgłoszenie (uznane za niesłuszne)
  Future<void> _removeOnlyReport(Report report) async {
    final result = await _reportRepository.removeReport(report.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result != null
            ? 'Report has been removed.'
            : 'An error occurred while removing the report.'),
      ),
    );
    setState(() {
      _reportsFuture = _reportRepository.fetchReports();
    });
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
      await Supabase.instance.client.auth.signOut();
      await UserPreferences.clearAll();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  // Pobierz przepis po ID (z cache lub z bazy)
  Future<Recipe?> _fetchRecipe(int recipeId) async {
    if (_recipesCache.containsKey(recipeId)) {
      return _recipesCache[recipeId];
    }
    final recipe = await _recipeRepository.getRecipeById(recipeId);
    if (recipe != null) {
      _recipesCache[recipeId] = recipe;
    }
    return recipe;
  }

  // Pobierz kroki przepisu po ID (z cache lub z bazy)
  Future<List<Map<String, dynamic>>> _fetchRecipeSteps(int recipeId) async {
    if (_stepsCache.containsKey(recipeId)) {
      return _stepsCache[recipeId]!;
    }
    final steps = await _recipeRepository.fetchRecipeStepsByRecipeId(recipeId) ?? [];
    _stepsCache[recipeId] = steps;
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No reports.'));
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
                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
                  ),
                  secondaryBackground: Container(
                    color: Colors.orange,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                  ),
                  confirmDismiss: (direction) async {
                    if (report.commentId != null) {
                      if (direction == DismissDirection.startToEnd) {
                        await _removeReportAndContent(report);
                      } else if (direction == DismissDirection.endToStart) {
                        await _removeOnlyReport(report);
                      }
                    } else if (report.recipeId != null) {
                      final recipe = await _fetchRecipe(report.recipeId!);
                      if (direction == DismissDirection.startToEnd) {
                        await _removeReportAndContent(report, recipe: recipe);
                      } else if (direction == DismissDirection.endToStart) {
                        await _removeOnlyReport(report);
                      }
                    }
                    return false;
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: report.commentId != null
                          ? FutureBuilder<RecipeComment?>(
                              future: _fetchComment(report.commentId!),
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
                                        Text('Author: ${comment.userName}'),
                                      Text('Content: ${comment.comment}'),
                                      Text('Rating: ${comment.rating}'),
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
                                      Text('No comment data'),
                                    ],
                                    if (report.recipeId != null)
                                      Text('Recipe ID: ${report.recipeId}'),
                                    Text('Reported by: ${report.userId}'),
                                  ],
                                );
                              },
                            )
                          : report.recipeId != null
                              ? FutureBuilder<Recipe?>(
                                  future: _fetchRecipe(report.recipeId!),
                                  builder: (context, recipeSnapshot) {
                                    if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final recipe = recipeSnapshot.data;
                                    if (recipe == null) {
                                      return const Text('No recipe data');
                                    }
                                    return FutureBuilder<List<Map<String, dynamic>>>(
                                      future: _fetchRecipeSteps(recipe.id),
                                      builder: (context, stepsSnapshot) {
                                        final steps = stepsSnapshot.data ?? [];
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.description ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 8),
                                            Text('Recipe name: ${recipe.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            if (recipe.description != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                                                child: Text('Description: ${recipe.description}'),
                                              ),
                                            if (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty)
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  '${constants.picsBucketUrl}/${recipe.photoUrl!}',
                                                  height: 80,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
                                                ),
                                              ),
                                            if(recipe.photoUrl !=null && recipe.photoUrl!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text('Photo URL: ${recipe.photoUrl}'),
                                              ),
                                              
                                            if (steps.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ...steps.map((step) => Text('${step['order'] ?? ''}. ${step['description'] ?? ''}')),
                                            ],
                                            if (recipe.creatorId == null)
                                              const Padding(
                                                padding: EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  'This is an admin recipe and cannot be removed.',
                                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            Text('Reported by: ${report.userId}'),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              : const Text('No report data'),
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