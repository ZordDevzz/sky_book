import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/services/language_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final bookRepo = Provider.of<BookRepository>(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(20),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home_outlined),
                    const SizedBox(width: 8.0),
                    Text(
                      lang.t('home'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Book? book = await bookRepo.getBookById(
                "06730485-6309-48f4-8415-4937bae317ae",
              );
              String bookname = book != null ? book.title : "Not found";
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(bookname), showCloseIcon: true),
                );
              }
            },
            child: const Text('Button'),
          ),
        ],
      ),
    );
  }
}
