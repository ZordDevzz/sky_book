import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/navigation/app_navigation.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/screens/discover/discover_provider.dart';
import 'package:sky_book/screens/home/home_provider.dart';
import 'package:sky_book/screens/leaderboard/leaderboard_provider.dart';
import 'package:sky_book/screens/profile/profile_provider.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart';
import 'package:sky_book/services/database_service.dart';
import 'package:sky_book/theme/theme_provider.dart';
import 'package:sky_book/utils/ui/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().database;
  _testDb();
  runApp(const MyApp());
}

_testDb() async {
  final bookRepository = BookRepository();
  final books = await bookRepository.fetchFeaturedBooks();
  for (var book in books) {
    print('Book Title: ${book.title}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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