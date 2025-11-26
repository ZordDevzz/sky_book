import 'package:sky_book/models/chapter.dart';
import 'package:sky_book/screens/reader/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/screens/book_details/book_details_provider.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookDetailsProvider(
        Provider.of<BookRepository>(context, listen: false),
        Provider.of<ChapterRepository>(context, listen: false),
        bookId,
      ),
      child: const _BookDetailsView(),
    );
  }
}

class _BookDetailsView extends StatelessWidget {
  const _BookDetailsView();

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<BookDetailsProvider, ShelfProvider>(
      builder: (context, detailsProvider, shelfProvider, _) {
        return Scaffold(
          body: Stack(
            children: [
              if (detailsProvider.book?.coverImageUrl != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.asset(
                      "assets/images/thumbnails/${detailsProvider.book!.coverImageUrl!}",
                      fit: BoxFit.cover,
                      height: 260,
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.surface,
                      colorScheme.surface.withOpacity(0.92),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Column(
                children: [
                  _Header(lang: lang),
                  Expanded(
                    child: detailsProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : detailsProvider.book == null
                            ? Center(child: Text(lang.t('book_not_found')))
                            : _Body(
                                book: detailsProvider.book!,
                                lang: lang,
                                detailsProvider: detailsProvider,
                                shelfProvider: shelfProvider,
                              ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lang});
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Text(
              lang.t('details'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.book,
    required this.lang,
    required this.detailsProvider,
    required this.shelfProvider,
  });

  final Book book;
  final LanguageProvider lang;
  final BookDetailsProvider detailsProvider;
  final ShelfProvider shelfProvider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBookOnShelf = shelfProvider.isBookOnShelf(book.bookId);
    final shelvedBookInfo = shelfProvider.getShelvedBookInfo(book.bookId);
    Chapter? lastReadChapter;
    if (shelvedBookInfo?.lastReadChapterIndex != null && detailsProvider.chapters.isNotEmpty) {
      try {
        lastReadChapter = detailsProvider.chapters.firstWhere((c) => c.chapterIndex == shelvedBookInfo!.lastReadChapterIndex);
      } catch(e) {
        lastReadChapter = null;
      }
    }


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              book.author?.name ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            icon: Icons.star_rate_rounded,
                            label: '${(book.rating ?? 0).toStringAsFixed(1)}/5',
                            color: colorScheme.primary,
                          ),
                          _Pill(
                            icon: Icons.visibility,
                            label:
                                '${book.viewCountWeekly} ${lang.t('views_week')}',
                            color: colorScheme.primary,
                          ),
                          if (book.tags.isNotEmpty)
                            ...book.tags.map(
                              (tag) => _Pill(
                                icon: Icons.label_outline,
                                label: tag.name,
                                color: colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBookOnShelf
                        ? null
                        : () async {
                            await shelfProvider.addBookToShelf(book.bookId);
                            // No need to refresh, ShelfProvider will notify listeners
                          },
                    icon: isBookOnShelf
                        ? const Icon(Icons.check)
                        : const Icon(Icons.library_add_outlined),
                    label: Text(
                      isBookOnShelf
                          ? lang.t('added_to_shelf')
                          : lang.t('add_to_shelf'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (detailsProvider.chapters.isEmpty) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(
                            book: book,
                            chapters: detailsProvider.chapters,
                            currentChapter: detailsProvider.chapters.first,
                          ),
                        ),
                      );
                      shelfProvider.update();
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(lang.t('read_from_first')),
                  ),
                ),
              ],
            ),
            if (shelvedBookInfo?.lastReadChapterIndex != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(
                          book: book,
                          chapters: detailsProvider.chapters,
                          currentChapter: lastReadChapter!,
                        ),
                      ),
                    );
                    shelfProvider.update();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    '${lang.t('continue_reading')} ${lastReadChapter!.title}',
                  ),
                ),
              ),
            ],
            if (isBookOnShelf) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await shelfProvider.removeBookFromShelf(book.bookId);
                    shelfProvider.update();
                  },
                  icon: const Icon(Icons.bookmark_remove),
                  label: Text(lang.t('remove_from_shelf')),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              lang.t('description'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                book.description ?? lang.t('no_description_available'),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ChaptersList(),
          ],
        ),
      ),
    );
  }
}

class _ChaptersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookDetailsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.chapters.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                colorScheme.outlineVariant,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      itemBuilder: (context, index) {
        final chapter = provider.chapters[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReaderScreen(
                  book: provider.book!,
                  chapters: provider.chapters,
                  currentChapter: chapter,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
