import 'package:flutter/material.dart';
import 'package:barmate/constants.dart' as constants;

class PublicUserProfileWidget extends StatelessWidget {
  final String username;
  final String? userTitle;
  final String? userBio;
  final String? userAvatarUrl;
  final VoidCallback onFollowTap;
  final bool isFollowing;

  const PublicUserProfileWidget({
    super.key,
    required this.username,
    this.userTitle,
    this.userBio,
    this.userAvatarUrl,
    required this.onFollowTap,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          // Avatar section
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    userAvatarUrl != null
                        ? NetworkImage(
                          '${constants.profilePicsUrl}/${userAvatarUrl!}',
                        )
                        : const AssetImage('images/unavailable-image.jpg')
                            as ImageProvider,
              ),
            ),
            Expanded(
              // User info section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userBio ?? "No bio available",
                    style: const TextStyle(fontSize: 16),
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
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: onFollowTap,
                icon: Icon(isFollowing ? Icons.check : Icons.add),
                label: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
