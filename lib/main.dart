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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<DatabaseService>(context, listen: false).connectionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing database: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return Consumer2<ThemeProvider, AuthProvider>(
            builder: (context, themeProvider, auth, _) {
              final isReady = auth.isReady;
              return MaterialApp(
                title: 'Thiên Thư',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                home: isReady
                    ? const AppNavigation()
                    : const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
              );
            },
          );
        }
      },
    );
  }
}
