import 'package:flutter/material.dart';
import 'package:sky_book/navigation/app_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thiên Thư',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppNavigation(),
    );
  }
}