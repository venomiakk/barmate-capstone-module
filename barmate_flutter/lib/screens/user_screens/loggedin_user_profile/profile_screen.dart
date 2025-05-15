import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/edit_profile_screen.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/favourite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/user_profile_feed_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/user_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:barmate/Utils/user_shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var logger = Logger(printer: PrettyPrinter());
  final LoggedinUserProfileController _controller =
      LoggedinUserProfileController.create();
  String? userTitle;
  String? userBio;

  // Dodaj nowe zmienne stanu
  String userName = '';
  String userId = '';
  String? userTitleFromPrefs;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPrefsData(); // Dodaj tę metodę
  }

  // Dodaj tę metodę do ładowania danych z preferencji
  Future<void> _loadPrefsData() async {
    try {
      final prefs = await UserPreferences.getInstance();
      setState(() {
        userName = prefs.getUserName();
        userId = prefs.getUserId();
        userTitleFromPrefs = prefs.getUserTitle();
      });
      logger.i("""
        Username: $userName,
        ID: $userId,
        Title: $userTitleFromPrefs
      """);
    } catch (e) {
      logger.e("Błąd podczas ładowania preferencji: $e");
    }
  }

  Future<void> _loadData() async {
    logger.d("_loadData");
    userTitle = await _controller.loadUserTitle();
    userBio = await _controller.getUserBio();
    await _controller.loadFavouriteDrinks();
    setState(() {});
  }

  void _navigateToEditProfile() async {
    logger.d("Navigate to profile settings");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                EditProfileScreen(userTitle: userTitle, userBio: userBio),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        userTitle = result['title'];
        userBio = result['bio'];
      });
      // Odśwież dane po powrocie z ekranu ustawień
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usuń bezpośrednie wywołania UserPreferences tutaj
    logger.i("""
      UserPage build method called
      Username: $userName,
      ID: $userId,
      Title: $userTitleFromPrefs
    """);
    // Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              logger.d("Favorite/history button pressed");
              // New page with favorite drinks and history
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              logger.d("Share button pressed");
              // Share profile functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              logger.d("Settings button pressed");
              // Navigate to overall settings page
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logger.d("Logout button pressed");
              _controller.logoutConfiramtionTooltip(context);
              // Logout functionality
              // Needs to ask for confirmation
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileWidget(
              username: userName,
              userTitle: userTitle,
              userBio: userBio,
              onSettingsTap: _navigateToEditProfile,
            ),
            const SizedBox(height: 16),
            FavouriteDrinksListWidget(),
            const SizedBox(height: 16),
            UserProfileFeedWidget(),
          ],
        ),
      ),
    );
  }
}
