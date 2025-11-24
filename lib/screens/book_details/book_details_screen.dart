import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/repositories/author_repository.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/repositories/tag_repository.dart';
import 'package:sky_book/services/database_service.dart';
import 'package:sky_book/services/language_provider.dart';
import 'book_details_provider.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookDetailsProvider(
        BookRepository(
          dbService: Provider.of<DatabaseService>(context, listen: false),
          authorRepository: AuthorRepository(dbService: Provider.of<DatabaseService>(context, listen: false)),
          tagRepository: TagRepository(dbService: Provider.of<DatabaseService>(context, listen: false)),
        ),
        ChapterRepository(dbService: Provider.of<DatabaseService>(context, listen: false)),
        bookId,
      ),
      child: Consumer<BookDetailsProvider>(
        builder: (context, provider, _) {
          final lang = Provider.of<LanguageProvider>(context);
          return Scaffold(
            body: Column(
              children: [
                // Custom App Bar
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          lang.t('details'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.book == null
                          ? Center(child: Text(lang.t('book_not_found')))
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Thumbnail
                                    SizedBox(
                                      width: 180,
                                      height: 240,
                                      child: provider.book!.coverImageUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.asset(
                                                "assets/images/thumbnails/${provider.book!.coverImageUrl!}",
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: const Icon(Icons.book, size: 80, color: Colors.grey),
                                            ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    // Title
                                    Text(
                                      provider.book!.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Author
                                    Text(
                                      provider.book!.author?.name ?? 'Unknown',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Divider(),
                                    const SizedBox(height: 16.0),
                                    // Action Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Placeholder
                                          },
                                          icon: const Icon(Icons.library_add_outlined),
                                          label: Text(lang.t('add_to_shelf')),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Placeholder
                                          },
                                          icon: const Icon(Icons.play_circle_outline),
                                          label: Text(lang.t('read_from_beginning')),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    // Description
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.t('description'),
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          provider.book!.description ?? lang.t('no_description_available'),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    // Chapter List
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.t('chapters'),
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8.0),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: provider.chapters.length,
                                          itemBuilder: (context, index) {
                                            final chapter = provider.chapters[index];
                                            return ListTile(
                                              leading: Text("${index + 1}"),
                                              title: Text(chapter.title),
                                              onTap: () {
                                                // Placeholder
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
