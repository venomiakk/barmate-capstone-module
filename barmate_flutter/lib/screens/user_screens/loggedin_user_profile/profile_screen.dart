import 'package:barmate/controllers/loggedin_user_profile_controller.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/edit_profile_screen.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/favourite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/user_profile_widget.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/drink_card_widget.dart'; // Add this import
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
  String? userAvatarUrl;

  // Dodaj nowe zmienne stanu
  String userName = '';
  String userId = '';
  String? userTitleFromPrefs;
  List<FavouriteDrink> favouriteDrinks = [];

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
    setState(() {});
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
      setState(() {
        userTitle = result['title'];
        userBio = result['bio'];
      });

      // Odśwież wszystkie dane po powrocie z ekranu ustawień
      await _loadData();
      await _loadPrefsData(); // Dodaj to, aby odświeżyć również dane z preferencji
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usuń bezpośrednie wywołania UserPreferences tutaj
    // logger.i("""
    //   UserPage build method called
    //   Username: $userName,
    //   ID: $userId,
    //   Title: $userTitleFromPrefs
    // """);
    // Size size = MediaQuery.of(context).size;
    // logger.i("Avatar URL: $userAvatarUrl");
    // logger.i("favouriteDrinks: $favouriteDrinks");
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
              height: 170, // Adjust height as needed
              child: FavouriteDrinksListWidget(initialDrinks: favouriteDrinks),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Your Recipes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // TODO: Replace with actual custom recipes
            // Center(
            //   child: Text(
            //     'You don't have any recipes yet.',
            //     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            //   ),
            // ),
            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 120,
                      child: DrinkCardWidget(
                        drink: Drink(
                          id: 999,
                          recipeId: 999,
                          name: "My Bloody Mary",
                          imageUrl:
                              "bloody_mary.jpg", // Użyje domyślnego obrazka
                        ),
                        onTap: () {
                          logger.d("Custom recipe tapped");
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
