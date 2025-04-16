import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/supabase_service/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _future = Supabase.instance.client
      .from('recipe')
      .select();
  final authService = AuthService();
  final RecipeService recipeService = RecipeService();
  
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
    return Scaffold(
      appBar: getAppBar(),
      body: SafeArea(
        child:Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20), // Adjust the height as needed
              featured(),
            ],
          ),
        )
        ,)
    );
  }

  PreferredSize getAppBar() {
    final  DateTime now = DateTime.now();
    final  int hour = now.hour;
    const double fontSize1 = 22;
    const double fontSize2 = 18;
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 70),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: hour < 12
                      ? [
                          const Icon(Icons.wb_sunny, size: 30),
                          const SizedBox(width: 10),
                          const Text(
                            'Good Morning',
                            style: TextStyle(fontSize: fontSize2),
                          ),
                        ] :
                      hour < 18
                          ? [
                              const Icon(Icons.wb_sunny, size: 30),
                              const SizedBox(width: 10),
                              const Text(
                                'Good Afternoon',
                                style: TextStyle(fontSize: fontSize2),
                              ),
                            ]
                          : [
                              const Icon(Icons.nights_stay, size: 30),
                              const SizedBox(width: 10),
                              const Text(
                                'Good Evening',
                                style: TextStyle(fontSize: fontSize2),
                              ),
                            ],
                       
                ),
                Text(
                  'user name',
                  style: TextStyle(fontSize: fontSize1, fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    );
    
  }

  Container featured() {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Featured',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            const SizedBox(height: 10),
            
          ],
        )
      );
  }
}
