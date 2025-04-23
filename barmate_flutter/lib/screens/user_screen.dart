import 'package:barmate/auth/auth_service.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final authService = AuthService();
  void logout() async {
    try {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              SizedBox(
                height: size.height * 0.08, // Adjust the height as needed
                child: Stack(
                  children: [
                    // Centered "Account" text
                    Align(
                      alignment: Alignment.center,
                      child: const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Logout icon on the right
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          size: 30,
                          color: Colors.grey,
                        ),
                        onPressed: logout, // Link the logout function here
                      ),
                    ),
                  ],
                ),
              ), // Adjust the height as needed

              SizedBox(height: size.height * 0.03),
              Container(
                width: size.width * 0.9,
                height: size.height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: userProfile(),
              ),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Align(
                  alignment:
                      Alignment.centerLeft, // Aligns the text to the left
                  child: Text(
                    'My favorite drinks',
                    textAlign:
                        TextAlign.left, // Ensures the text is left-aligned
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row userProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
      crossAxisAlignment: CrossAxisAlignment.center, // Vertically center items
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ), // Add some spacing
          child: Container(
            width: 80,
            height: 80,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Image(image: AssetImage('images/profile_picture.png')),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'User Name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('User title', style: TextStyle(fontSize: 18)),
          ],
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey, size: 40),
            onPressed: () {
              // Add your edit profile action here
            },
          ),
        ),

        // Pushes the icon to the right
      ],
    );
  }
}
