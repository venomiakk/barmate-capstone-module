import 'package:flutter/material.dart';
import 'package:barmate/repositories/report_repository.dart';
import 'package:barmate/model/report_model.dart';

class CheckReportsScreen extends StatefulWidget {
  const CheckReportsScreen({super.key});

  @override
  State<CheckReportsScreen> createState() => _CheckReportsScreenState();
}

class _CheckReportsScreenState extends State<CheckReportsScreen> {
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ReportRepository().fetchReports();
  }

  // Funkcja wywoływana po przeciągnięciu w prawo
  void _onSwipeRight(Report report) {
    // TODO: Dodaj logikę np. zaakceptowania/rozpatrzenia zgłoszenia
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Przeciągnięto w prawo: ${report.description}')),
    );
  }

  // Funkcja wywoływana po przeciągnięciu w lewo
  void _onSwipeLeft(Report report) {
    // TODO: Dodaj logikę np. odrzucenia zgłoszenia
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Przeciągnięto w lewo: ${report.description}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zgłoszenia')),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Dismissible(
                  key: ValueKey(
                      '${report.commentId}_${report.recipeId}_${report.userId}_${index}'),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 32),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.description,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          if (report.commentId != null)
                            Text('Komentarz ID: ${report.commentId}'),
                          if (report.recipeId != null)
                            Text('Przepis ID: ${report.recipeId}'),
                          Text('Zgłaszający: ${report.userId}'),
                        ],
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