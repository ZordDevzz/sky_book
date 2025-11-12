import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'package:sky_book/screens/home_screen.dart';
import 'package:sky_book/screens/shelf_screen.dart';
import 'package:sky_book/screens/discover_screen.dart';
import 'package:sky_book/screens/leaderboard_screen.dart';
import 'package:sky_book/screens/profile_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 2;

  final List<Widget> _screens = const [
    ShelfScreen(),
    DiscoverScreen(),
    HomeScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  final List<String> _screenTitles = const [
    'My Shelf',
    'Discover',
    'Home',
    'Leaderboard',
    'Profile',
  ];

  NavigationItem _buildButton(String label, IconData icon) {
    return NavigationItem(label: Text(label), child: Icon(icon));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(_screenTitles[_selectedIndex]),
          subtitle: authProvider.isAuthenticated
              ? Text('Welcome, ${authProvider.currentUser!.username}')
              : const Text('Your reliable reading companion.'),
          trailing: [
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () {
                // TODO: Implement search
              },
              child: const Icon(LucideIcons.search),
            ),
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () => themeProvider.toggleTheme(),
              child: Icon(isDark ? LucideIcons.sun : LucideIcons.moon),
            ),
          ],
        ),
        const Divider(),
      ],
      footers: [
        const Divider(),
        NavigationBar(
          onSelected: (i) {
            setState(() {
              _selectedIndex = i;
            });
          },
          index: _selectedIndex,
          children: [
            _buildButton('Shelf', LucideIcons.bookOpen),
            _buildButton('Discover', LucideIcons.compass),
            _buildButton('Home', LucideIcons.house),
            _buildButton('Rankings', LucideIcons.trophy),
            _buildButton('Profile', LucideIcons.circleUserRound),
          ],
        ),
      ],
      child: IndexedStack(index: _selectedIndex, children: _screens),
    );
  }
}
