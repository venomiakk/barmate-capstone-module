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
      LoggedinUserProfileController();
  String? userTitle;
  String? userBio;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    logger.d("_loadData");
    userTitle = await _controller.loadUserTitle();
    userBio = await _controller.getUserBio();
    await _controller.loadFavouriteDrinks();
    setState(() {});
  }

  void _navigateToSettings() async {
    logger.d("Navigate to profile settings");
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProfileScreen(
        userTitle: userTitle,
        userBio: userBio,
      ),
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
    logger.d("""
      UserPage build method called
      Username: ${UserPreferences().getUserName()},
      ID: ${UserPreferences().getUserId()},
      Title: ${UserPreferences().getUserTitle()}
      """);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Mam wrażenie, że to jest niepotrzebne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: const [
                Text(
                  "Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 8),
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Icon(Icons.logout),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            UserProfileWidget(
              userTitle: userTitle,
              userBio: userBio,
              onSettingsTap: _navigateToSettings,
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
