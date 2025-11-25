import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/navigation/app_navigation.dart';
import 'package:sky_book/providers_container.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/database_service.dart';
import 'package:sky_book/services/theme_provider.dart';
import 'package:sky_book/utils/ui/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void>? _initFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initFuture == null) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _initFuture = Future.wait([
        dbService.connectionFuture,
        themeProvider.initializationFuture,
        authProvider.initializationFuture,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Text('Error initializing app: ${snapshot.error}'))),
          );
        } else {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'Thiên Thư',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                home: const AppNavigation(),
              );
            },
          );
        }
      },
    );
  }
}
