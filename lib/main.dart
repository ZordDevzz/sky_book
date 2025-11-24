import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/navigation/app_navigation.dart';
import 'package:sky_book/screens/discover/discover_provider.dart';
import 'package:sky_book/screens/home/home_provider.dart';
import 'package:sky_book/screens/leaderboard/leaderboard_provider.dart';
import 'package:sky_book/screens/profile/profile_provider.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart';
import 'package:sky_book/services/theme_provider.dart';
import 'package:sky_book/services/language_provider.dart';
import 'package:sky_book/utils/ui/themes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ShelfProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Thiên Thư',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppNavigation(),
          );
        },
      ),
    );
  }
}
