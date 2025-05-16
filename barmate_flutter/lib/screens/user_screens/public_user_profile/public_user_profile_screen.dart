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

  // User data
  String username = '';
  String? userTitle;
  String? userBio;
  String? userAvatarUrl;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // TODO: Implement a controller to load user data by userId
    // This is where you would fetch the user data from your backend
    // For now, we'll use placeholder data

    // Simulating a network delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      username = "JohnDoe";
      userTitle = "Cocktail Enthusiast";
      userBio = "I love trying new cocktails.";
      userAvatarUrl = null; // Replace with actual URL when available
    });
  }

  void _handleFollowTap() {
    // TODO: Implement follow/unfollow functionality with your backend
    setState(() {
      isFollowing = !isFollowing;
    });

    logger.d(isFollowing ? "Following user" : "Unfollowed user");

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
    logger.i("Building PublicUserProfileScreen for userId: ${widget.userId}");
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

            // TODO: Add favorite drinks list widget
            const SizedBox(
              height: 170,
              child: Center(
                child: Text("User's favorite drinks will appear here"),
              ),
            ),

            const SizedBox(height: 24),

            // User's feed/posts section
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Recent Activity',
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
