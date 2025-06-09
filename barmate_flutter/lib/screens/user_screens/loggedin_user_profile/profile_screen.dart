import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/controllers/public_profile_controller.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/edit_profile_screen.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/favourite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/user_profile_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/drink_card_widget.dart'; // Add this import
import 'package:barmate/screens/user_screens/profile/settings_screen.dart';
import 'package:barmate/screens/user_screens/profile/user_history.dart';
import 'package:barmate/screens/user_screens/profile/widgets/users_recipes_list.dart';
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
  final PublicUserProfileController _publicController =
      PublicUserProfileController.create();
  String? userTitle;
  String? userBio;
  String? userAvatarUrl;

  // Dodaj nowe zmienne stanu
  String userName = '';
  String userId = '';
  String? userTitleFromPrefs;
  List<FavouriteDrink> favouriteDrinks = [];
  bool _isLoading = true; // Dodaj tę zmienną

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPrefsData();
  }

  // Dodaj tę metodę do ładowania danych z preferencji
  Future<void> _loadPrefsData() async {
    try {
      final prefs = await UserPreferences.getInstance();
      if (mounted) {
        // Sprawdź, czy widget jest zamontowany przed aktualizacją stanu
        setState(() {
          userName = prefs.getUserName();
          userId = prefs.getUserId();
          userTitleFromPrefs = prefs.getUserTitle();
        });
      }
      // logger.i("""
      //   Username: $userName,
      //   ID: $userId,
      //   Title: $userTitleFromPrefs
      // """);
    } catch (e) {
      logger.e("Error loading preferences: $e");
    }
  }

  Future<void> _loadData() async {
    // logger.d("_loadData");
    userTitle = await _controller.loadUserTitle();
    userBio = await _controller.getUserBio();
    userAvatarUrl = await _controller.loadUserAvatarUrl();
    favouriteDrinks = await _controller.loadUserFavouriteDrinks();
    if (mounted) {
      setState(() {
        _isLoading = false; // Zakończ ładowanie
      });
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(
              userTitle: userTitle,
              userBio: userBio,
              userImageUrl: userAvatarUrl,
            ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (mounted) {
        setState(() {
          userTitle = result['title'];
          userBio = result['bio'];
        });
        // Sprawdź, czy widget jest zamontowany przed aktualizacją stanu
      }

      // Odśwież wszystkie dane po powrocie z ekranu ustawień
      await _loadData();
      await _loadPrefsData(); // Dodaj to, aby odświeżyć również dane z preferencji
    }
  }

  // Dodaj tę metodę do klasy _UserPageState
  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true; // Rozpocznij ładowanie przy odświeżaniu
      });
      await Future.wait([_loadData(), _loadPrefsData()]);
    } catch (e) {
      logger.e("Error refreshing profile data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // Zakończ ładowanie nawet przy błędzie
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Sprawdź czy userId nie jest pusty przed nawigacją
              if (userId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserHistoryScreen(userUuid: userId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User data not loaded yet'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _controller.logoutConfiramtionTooltip(context);
              // Logout functionality
              // Needs to ask for confirmation
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warunkowo wyświetl loader lub UserProfileWidget
              _isLoading
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : UserProfileWidget(
                    username: userName,
                    userTitle: userTitle,
                    userBio: userBio,
                    userAvatarUrl: userAvatarUrl,
                    onSettingsTap: _navigateToEditProfile,
                  ),
              const SizedBox(height: 24),

              // Add a title for the section
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Favorite Drinks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // Set a fixed height for the widget
              SizedBox(
                height: 170,
                child: FavouriteDrinksListWidget(
                  initialDrinks: favouriteDrinks,
                ),
              ),

              const SizedBox(height: 24),
              if (!_isLoading) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Your Recipes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 170,
                  child: UsersRecipesList(userId: userId, isCurrentUser: true),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
