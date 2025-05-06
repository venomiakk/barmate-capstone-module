import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:barmate/model/favourite_drink_model.dart';
import 'package:flutter/material.dart';
import 'package:barmate/screens/user_screens/settins_screen.dart';
import 'package:barmate/repositories/favourite_drinks_repository.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final authService = AuthService();
  final FavouriteDrinkRepository repository = FavouriteDrinkRepository();
  final List<FavouriteDrink> favouriteDrinks = [];

void loadFavouriteDrinks() async {
  try {
    final userId = UserPreferences().getUserId();
    final drinks = await repository.fetchFavouriteDrinksByUserId(userId);

    setState(() {
      favouriteDrinks.clear();
      favouriteDrinks.addAll(drinks);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
    );
  }
}

  String? userTitle;

  // List<String> favouriteDrinks = [
  //   'Mojito',
  //   'Negroni',
  //   'Old Fashioned',
  // ];

  List<String> drinkHistory = [
    'Bloody Mary',
    'Daiquiri',
    'Whiskey Sour',
  ];

  @override
  void initState() {
    super.initState();
    loadUserTitle();
    loadFavouriteDrinks();
  }

  void loadUserTitle() async {
    final title = await UserPreferences().getUserTitle();
    setState(() {
      userTitle = title;
    });
  }

  void logout() async {
    resetNotifiersToDefaults();
    try {
      UserPreferences.clear();
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  // Nowa metoda do nawigacji do SettingsPage i zaktualizowania tytułu
  void _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );

    // Jeśli otrzymaliśmy nowy tytuł, zaktualizuj userTitle
    if (result != null) {
      setState(() {
        userTitle = result; // Zaktualizuj tytuł użytkownika
      });
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
                height: size.height * 0.08,
                child: Stack(
                  children: [
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          size: 30,
                          color: Colors.grey,
                        ),
                        onPressed: logout,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                width: size.width * 0.9,
                height: size.height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: userProfile(),
              ),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'My favorite drinks',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              favouriteDrinksWidget(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drink history',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              drinkHistoryWidget(),
            ],
          ),
        ),
      ),
    );
  }

Widget favouriteDrinksWidget() {
  if (favouriteDrinks.isEmpty) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No favourite drinks',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            selectedPageNotifier.value = 1;
          },
          child: const Text(
            'Add new drinks',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  return Column(
    children: [
      SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: favouriteDrinks.length,
          itemBuilder: (context, index) {
            final drink = favouriteDrinks[index];
            return drinkCard(drink.drinkName, () {
              setState(() {
                favouriteDrinks.removeAt(index);
              });
            });
          },
        ),
      )
    ],
  );
}


  Widget drinkHistoryWidget() {
    if (drinkHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No drink history available',
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: drinkHistory.length,
        itemBuilder: (context, index) {
          final drink = drinkHistory[index];
          return drinkCard(drink, () {
            setState(() {
              drinkHistory.removeAt(index);
            });
          });
        },
      ),
    );
  }

  Widget drinkCard(String drink, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                drink,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row userProfile() {
    String username = UserPreferences().getUserName();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
          children: [
            Text(
              username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              userTitle ?? 'User title',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey, size: 40),
            onPressed: _navigateToSettings, // Zmieniona metoda
          ),
        ),
      ],
    );
  }
}
