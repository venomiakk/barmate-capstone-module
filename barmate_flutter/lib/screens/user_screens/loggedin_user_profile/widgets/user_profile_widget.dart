import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserProfileWidget extends StatelessWidget {
  final String? userTitle;
  final String? userBio;
  final String? username;
  final String? userAvatarUrl;
  final VoidCallback onSettingsTap;

  const UserProfileWidget({
    super.key,
    required this.username,
    required this.userTitle,
    required this.userBio,
    required this.userAvatarUrl,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    var logger = Logger(printer: PrettyPrinter());
    return Column(
      children: [
        Row(
          // *: Avatar section
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    userAvatarUrl != null
                        ? NetworkImage(userAvatarUrl!)
                        : AssetImage('images/unavailable-image.jpg')
                            as ImageProvider,
              ),
            ),
            Expanded(
              // *: User info section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username!,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userBio ?? "No bio available",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  userTitle ?? "No title available",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  onSettingsTap();
                },
                child: const Text(
                  "Edit profile",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
