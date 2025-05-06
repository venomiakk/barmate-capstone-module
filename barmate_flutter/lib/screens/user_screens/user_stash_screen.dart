import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:barmate/repositories/stash_repository.dart';
import 'package:barmate/Utils/colors.dart';

class UserStashScreen extends StatefulWidget {
  const UserStashScreen({super.key});

  @override
  State<UserStashScreen> createState() => _UserStashScreenState();
}

class _UserStashScreenState extends State<UserStashScreen> {
  final UserStashRepository repository = UserStashRepository();
  final List<UserStash> stash = [];

  @override
  void initState() {
    super.initState();
    _loadStash();
  }

  Future<void> _loadStash() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    print('Logged in as: $userId');

    if (userId == null) {
      print('User not logged in');
      return;
    }

    final fetchedStash = await repository.fetchUserStash(userId);
    setState(() {
      stash.clear();
      stash.addAll(fetchedStash);
      print('Fetched stash: $fetchedStash');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    'Your Stash',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
 
              ],
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.8,
                ),
                itemCount: stash.length,
                itemBuilder: (context, index) {
                  final entry = stash[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('images/przyklad.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: 160,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                            .scaffoldBackgroundColor.withOpacity(0.9),
                                    Theme.of(context)
                                            .scaffoldBackgroundColor.withOpacity(0.5),
                                    Theme.of(context)
                                            .scaffoldBackgroundColor.withOpacity(0.1),
                                  ],
                                  stops: [0.0, 0.6, 1.0],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    entry.ingredientName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.local_drink, size: 13,),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${entry.amount}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
