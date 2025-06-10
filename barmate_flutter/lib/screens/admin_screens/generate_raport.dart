import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/constants.dart' as constants;
import 'package:barmate/data/notifiers.dart';
import 'package:barmate/repositories/favourite_drinks_repository.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/loggedin_user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GenerateRaport extends StatefulWidget {
  const GenerateRaport({super.key});

  @override
  State<GenerateRaport> createState() => _GenerateRaportState();
}

class _GenerateRaportState extends State<GenerateRaport> {
  final authService = AuthService();
  final FavouriteDrinkRepository favouriteDrinkRepository = FavouriteDrinkRepository();
  final RecipeRepository recipeRepository = RecipeRepository();
  final LoggedinUserProfileRepository userProfileRepository = LoggedinUserProfileRepository();


  final List<String> reportTypes = [
    'Favourite Drinks',
    'Most Popular Drinks',
    'Created accounts statistics',
  ];
  final List<String> timeFilters = [
    'All Time',
    'Last 30 Days',
    'Last 14 Days',
    'Last Week',
    'Today'
  ];

  String selectedReportType = 'Favourite Drinks';
  String selectedTimeFilter = 'All Time';

  List<Map<String, dynamic>> generatedReport = [];

  Future<void> generateReport() async {
    DateTime? fromDate;
    DateTime? toDate;
    final now = DateTime.now();

    // Set date range based on selectedTimeFilter
    switch (selectedTimeFilter) {
      case 'Last 30 Days':
        fromDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 14 Days':
        fromDate = now.subtract(const Duration(days: 14));
        break;
      case 'Last Week':
        fromDate = now.subtract(const Duration(days: 7));
        break;
      case 'Today':
        fromDate = DateTime(now.year, now.month, now.day);
        //toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'All Time':
      default:
        fromDate = null;
        toDate = null;
    }

    if (selectedReportType == 'Favourite Drinks') {
      final report = await favouriteDrinkRepository.fetchFavouriteDrinksReport(
        fromDate: fromDate,
        toDate: toDate,
      );

      List<Map<String, dynamic>> detailedReport = [];
      for (var item in report) {
        final recipeId = item['recipe_id'];
        final recipe = await recipeRepository.getRecipeById(recipeId);

        String? imageUrl;
        if (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty) {

          imageUrl = recipe.photoUrl!.startsWith('http')
              ? recipe.photoUrl
              : '${constants.picsBucketUrl}/${recipe.photoUrl}';
        } else {
          imageUrl = 'https://via.placeholder.com/80';
        }

        detailedReport.add({
          'name': recipe.name ?? 'Recipe #$recipeId',
          'count': item['count'],
          'image': imageUrl,
          'description': recipe.description ?? 'No description available',
        });
      }

      setState(() {
        generatedReport = detailedReport;
      });
    } else if (selectedReportType == 'Most Popular Drinks') {
      final report = await favouriteDrinkRepository.fetchMostPopularDrinksReport(
        fromDate: fromDate,
        toDate: toDate,
      );

      setState(() {
        generatedReport = report.map((item) => {
          'name': item['drink_name'],
          'avg_rating': item['avg_rating'],
          'ratings_count': item['ratings_count'],
          'image': item['photo_url'] != null && item['photo_url'].toString().isNotEmpty
              ? (item['photo_url'].toString().startsWith('http')
                  ? item['photo_url']
                  : '${constants.picsBucketUrl}/${item['photo_url']}')
              : 'https://via.placeholder.com/80',
          'recipe_id': item['recipe_id'], // <-- Add this line!
        }).toList();
      });
    } else if (selectedReportType == 'Created accounts statistics') {
      final accounts = await userProfileRepository.fetchCreatedAccountsReport(
        fromDate: fromDate,
        toDate: toDate,
      );
      setState(() {
        generatedReport = accounts.map((item) => {
          'login': item['login'] ?? 'Brak loginu',
          'created_at': item['created_at']?.toString() ?? '',
        }).toList();
      });
    }
  }

  void logout() async {
    resetNotifiersToDefaults();
    try {
      final prefs = await UserPreferences.getInstance();

      await prefs.clear();

      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with title and logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 30),
                    onPressed: logout,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filters section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Report Type:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: selectedReportType,
                        isExpanded: true,
                        items: reportTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReportType = value!;
                            generatedReport = [];
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text('Time Range:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: selectedTimeFilter,
                        isExpanded: true,
                        items: timeFilters
                            .map((filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTimeFilter = value!;
                          });
                          generateReport(); // Always fetch new data
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.analytics),
                          label: const Text('Generate Report'),
                          onPressed: generateReport,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (generatedReport.isNotEmpty) ...[
                Text(
                  selectedReportType == 'Favourite Drinks'
                      ? 'Favourite Drinks Report'
                      : selectedReportType == 'Most Popular Drinks'
                          ? 'Most Popular Drinks Report'
                          : selectedReportType == 'Created accounts statistics'
                              ? 'Created Accounts Report'
                              : 'Report Results',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (selectedReportType == 'Created accounts statistics') ...[
                  Text(
                    'Accounts created: ${generatedReport.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: generatedReport.length,
                      itemBuilder: (context, index) {
                        final user = generatedReport[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user['login'] ?? 'Brak loginu'),
                          subtitle: Text(
                            user['created_at'] != null && user['created_at']!.isNotEmpty
                                ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(user['created_at']!))
                                : '',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                          ),
                        );
                      },
                    ),
                  ),
                ]
                else ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: generatedReport.length,
                      itemBuilder: (context, index) {
                        final drink = generatedReport[index];
                        return GestureDetector(
                          onTap: () async {
                            if (selectedReportType == 'Most Popular Drinks') {
                              final recipeId = drink['recipe_id'] ?? drink['id'];
                              final dateRange = getCurrentDateRange();
                              final ratings = recipeId != null
                                  ? await fetchRatingsForRecipe(
                                      recipeId,
                                      fromDate: dateRange['fromDate'],
                                      toDate: dateRange['toDate'],
                                    )
                                  : <Map<String, dynamic>>[];

                              // Fetch logins for all user_ids in ratings
                              final userLogins = <String, String>{};
                              await Future.wait(ratings.map((r) async {
                                final userId = r['user_id'];
                                if (userId != null && !userLogins.containsKey(userId)) {
                                  userLogins[userId] = await userProfileRepository.fetchUserLogin(userId);
                                }
                              }));

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(
                                    drink['name'],
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(
                                          drink['image'],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.local_bar, size: 100),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Average rating: ${drink['avg_rating']}',
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Number of ratings: ${drink['ratings_count']}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const Divider(height: 32),
                                        const Text(
                                          'Ratings',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        if (ratings.isEmpty)
                                          const Text('No ratings yet.')
                                        else
                                          ...ratings.map((r) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '⭐ ${r['rating'] ?? '-'}',
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  userLogins[r['user_id']] ?? r['user_id'] ?? '',
                                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                ),
                                                const SizedBox(width: 10),
                                                if ((r['comment'] ?? '').toString().isNotEmpty)
                                                  TextButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          title: Text(userLogins[r['user_id']] ?? r['user_id'] ?? ''),
                                                          content: Text(r['comment']),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: const Text('Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: const Text('See comment'),
                                                  ),
                                              ],
                                            ),
                                          )),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close', style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Existing popup for Favourite Drinks
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(
                                    drink['name'],
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.network(
                                        drink['image'],
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.local_bar, size: 100),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        '❤︎ ${drink['count']}',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Description',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${drink['description']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close', style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // Drink image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    drink['image'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.local_bar, size: 40),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Drink info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        drink['name'],
                                        style: const TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Zamówienia tekst zamiast gwiazdki
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: selectedReportType == 'Most Popular Drinks'
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '⭐ ${drink['avg_rating']}',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '(${drink['ratings_count']} ratings)',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '❤︎ ${drink['count']}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, DateTime?> getCurrentDateRange() {
    DateTime? fromDate;
    DateTime? toDate;
    final now = DateTime.now();

    switch (selectedTimeFilter) {
      case 'Last 30 Days':
        fromDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 14 Days':
        fromDate = now.subtract(const Duration(days: 14));
        break;
      case 'Last Week':
        fromDate = now.subtract(const Duration(days: 7));
        break;
      case 'Today':
        fromDate = DateTime(now.year, now.month, now.day);
        break;
      case 'All Time':
      default:
        fromDate = null;
        toDate = null;
    }
    return {'fromDate': fromDate, 'toDate': toDate};
  }

  Future<List<Map<String, dynamic>>> fetchRatingsForRecipe(
    int recipeId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = recipeRepository.client
        .from('comments_recipe')
        .select('rating, user_id, comment, created_at')
        .eq('recipe_id', recipeId);

    if (fromDate != null) {
      query = query.gte('created_at', fromDate.toIso8601String());
    }
    if (toDate != null) {
      query = query.lte('created_at', toDate.toIso8601String());
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
}
