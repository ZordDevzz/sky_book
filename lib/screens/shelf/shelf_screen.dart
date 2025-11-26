import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/auth/auth_screen.dart';
import 'package:sky_book/screens/book_details/book_details_screen.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/language_provider.dart';
import 'package:sky_book/widgets/book_thumbnail.dart';

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('shelf'))),
      body: Stack(
        children: [
          Consumer<ShelfProvider>(
            builder: (context, shelfProvider, child) {
              if (shelfProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (shelfProvider.shelvedBooksInfo.isEmpty) {
                return Center(child: Text(lang.t('shelf_empty')));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: shelfProvider.shelvedBooksInfo.length,
                itemBuilder: (context, index) {
                  final shelvedBookInfo = shelfProvider.shelvedBooksInfo[index];
                  final book = shelvedBookInfo.book;
                  final shelf = shelvedBookInfo.shelf;
                  final totalChapters = shelvedBookInfo.totalChapters;
                  final lastReadChapterIndex =
                      shelvedBookInfo.lastReadChapterIndex;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookDetailsScreen(bookId: book.bookId),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BookThumbnail(
                            book: book,
                            shelf: shelf,
                            totalChapters: totalChapters,
                            lastReadChapterIndex: lastReadChapterIndex,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          book.author?.name.isNotEmpty == true
                              ? book.author!.name
                              : lang.t('unknown_author'),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          if (auth.isGuest)
            _GuestLockOverlay(
              message: lang.t('login_required'),
              actionLabel: lang.t('login_or_register'),
              onAction: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
              },
            ),
        ],
      ),
    );
  }
}

class _GuestLockOverlay extends StatelessWidget {
  const _GuestLockOverlay({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black.withOpacity(0.35),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onAction,
                      child: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
