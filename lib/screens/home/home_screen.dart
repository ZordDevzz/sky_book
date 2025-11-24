import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/home/home_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final provider = Provider.of<HomeProvider>(context);

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
            child: RefreshIndicator(
              onRefresh: () => provider.fetchBooks(),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      lang.t(
                        'featured_books',
                      ), // Assuming 'featured_books' key exists in language provider
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.featuredBooks.isEmpty
                        ? Center(child: Text(lang.t('no_books_found')))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(6.0),
                            itemCount: provider.featuredBooks.length,
                            itemBuilder: (context, index) {
                              final book = provider.featuredBooks[index];
                              return SizedBox(
                                width: 150,
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // Navigate to book details
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                bottom: Radius.circular(8.0),
                                              ),
                                          child: book.coverImageUrl != null
                                              ? Image.asset(
                                                  "assets/images/thumbnails/${book.coverImageUrl!}",
                                                  fit: BoxFit.fill,
                                                  height:
                                                      180, // Fixed image height
                                                )
                                              : const SizedBox(
                                                  height: 180,
                                                  child: Icon(
                                                    Icons.book,
                                                    size: 50,
                                                  ),
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            2.0,
                                            8.0,
                                            2.0,
                                            0.0,
                                          ),
                                          child: Text(
                                            book.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 12.0,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4.0),
                                              Expanded(
                                                child: Text(
                                                  book.author?.name ??
                                                      'Unknown',
                                                  style: const TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // if (book.tags.isNotEmpty)
                                        //   Padding(
                                        //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        //     child: Text(
                                        //       book.tags.first.name,
                                        //       style: const TextStyle(
                                        //         fontSize: 12.0,
                                        //         color: Colors.blue,
                                        //       ),
                                        //       maxLines: 1,
                                        //       overflow: TextOverflow.ellipsis,
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Divider(color: Colors.grey.withAlpha(100), thickness: 1.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
