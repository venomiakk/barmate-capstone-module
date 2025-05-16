import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/controllers/public_profile_controller.dart';
import 'package:barmate/screens/user_screens/public_user_profile/widgets/public_favorite_drinks_list_widget.dart';
import 'package:barmate/screens/user_screens/public_user_profile/widgets/public_user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PublicUserProfileScreen extends StatefulWidget {
  final String userId;

  const PublicUserProfileScreen({Key? key, required this.userId})
    : super(key: key);

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
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Recent Activity/ User drinks??',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // TODO: Add user feed widget
            const Center(child: Text("User's activity feed will appear here")),
          ],
        ),
      ),
    );
  }
}
