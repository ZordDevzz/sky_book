import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/services/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = Provider.of<BookRepository>(context, listen: false).getAllBooksWithAuthors();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

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
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(lang.t('no_books_found')));
                } else {
                  final books = snapshot.data!;
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return ListTile(
                        leading: book.coverImageUrl != null
                            ? Image.asset(
                                "assets/images/thumbnails/${book.coverImageUrl!}",
                                width: 50,
                                height: 80
                              )
                            : const Icon(Icons.book),
                        title: Text(book.title),
                        subtitle: Text(
                          book.author?.name ?? 'Unknown Author',
                        ), // Display author's name
                        onTap: () {
                          // Navigate to book details
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
