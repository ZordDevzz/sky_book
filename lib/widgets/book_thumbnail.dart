import 'package:flutter/material.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/shelf.dart';

class BookThumbnail extends StatelessWidget {
  final Book book;
  final Shelf? shelf;
  final int? totalChapters;
  final int? lastReadChapterIndex;

  const BookThumbnail({
    super.key,
    required this.book,
    this.shelf,
    this.totalChapters,
    this.lastReadChapterIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            width: 140,
            height: 190,
            child: book.coverImageUrl != null
                ? Image.asset(
                    "assets/images/thumbnails/${book.coverImageUrl!}",
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.book, size: 48),
                  ),
          ),
          if (lastReadChapterIndex != null && totalChapters != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '$lastReadChapterIndex/$totalChapters',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
