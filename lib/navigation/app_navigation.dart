import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/discover/discover_screen.dart';
import 'package:sky_book/screens/home/home_screen.dart';
import 'package:sky_book/screens/leaderboard/leaderboard_screen.dart';
import 'package:sky_book/screens/profile/profile_screen.dart';
import 'package:sky_book/screens/shelf/shelf_screen.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 2; // Set home as the default selected index

  static const List<Widget> _widgetOptions = <Widget>[
    ShelfScreen(),
    LeaderboardScreen(),
    HomeScreen(),
    DiscoverScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      ),
      bottomNavigationBar: Consumer<LanguageProvider>(
        builder: (context, lang, _) => BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: lang.t('shelf'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: lang.t('leaderboard'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: lang.t('home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: lang.t('discover'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: lang.t('profile'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
