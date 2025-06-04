import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/controllers/public_profile_controller.dart';
import 'package:barmate/screens/user_screens/loggedin_user_profile/widgets/drink_card_widget.dart';
import 'package:barmate/screens/user_screens/public_user_profile/widgets/public_favorite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/public_user_profile/widgets/public_user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PublicUserProfileScreen extends StatefulWidget {
  final String userId;

  const PublicUserProfileScreen({super.key, required this.userId});

  @override
  State<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {
  var logger = Logger(printer: PrettyPrinter());
  final PublicUserProfileController _controller =
      PublicUserProfileController.create();
  // User data
  String username = '';
  String? userTitle;
  String? userBio;
  String? userAvatarUrl;
  int? userId;
  String userUuid = '';
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _controller.getUserData(widget.userId);
      // TODO: implement follow loading
      setState(() {
        username = userData.username;
        userTitle = userData.title;
        userBio = userData.bio;
        userAvatarUrl = userData.avatarUrl;
        userId = userData.id;
        userUuid = userData.uuid;
      });
    } catch (e) {
      logger.e("Error loading user data: $e");
    }
  }

  Future<void> _handleFollowTap() async {
    // TODO: Implement follow/unfollow functionality with your backend
    setState(() {
      isFollowing = !isFollowing;
    });
    final prefs = await UserPreferences.getInstance();
    final loggedinUserId = prefs.getUserId();
    logger.f(
      "TODO: User $loggedinUserId clicked follow/unfollow button on user $userId, $userUuid",
    );
    logger.i(isFollowing ? "Following user" : "Unfollowed user");

    // Show a snackbar to indicate the action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowing
              ? 'You are now following $username'
              : 'You unfollowed $username',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // logger.i("Building PublicUserProfileScreen for userId: ${widget.userId}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              logger.d("Share button pressed");
              // Share profile functionality
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                logger.d("Report user selected");
                // Handle report functionality
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Text('Report user'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile information
            PublicUserProfileWidget(
              username: username,
              userTitle: userTitle,
              userBio: userBio,
              userAvatarUrl: userAvatarUrl,
              onFollowTap: _handleFollowTap,
              isFollowing: isFollowing,
            ),

            const SizedBox(height: 24),

            // Favorite drinks section
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Favorite Drinks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            userUuid.isNotEmpty
                ? PublicFavouriteDrinksWidget(
                  userId: widget.userId,
                  userUuid: userUuid,
                )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 24),

            // User's feed/posts section
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '$username\'s Recipes',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // TODO: Add users drniks
            // Center(
            //   child: Text(
            //     'This user has no recipes yet.',
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
