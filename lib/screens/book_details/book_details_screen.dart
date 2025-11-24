import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/repositories/author_repository.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/repositories/tag_repository.dart';
import 'package:sky_book/screens/book_details/book_details_provider.dart';
import 'package:sky_book/services/database_service.dart';
import 'package:sky_book/services/language_provider.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookDetailsProvider(
        BookRepository(
          dbService: Provider.of<DatabaseService>(context, listen: false),
          authorRepository: AuthorRepository(
            dbService: Provider.of<DatabaseService>(context, listen: false),
          ),
          tagRepository: TagRepository(
            dbService: Provider.of<DatabaseService>(context, listen: false),
          ),
        ),
        ChapterRepository(
          dbService: Provider.of<DatabaseService>(context, listen: false),
        ),
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
    return Consumer<BookDetailsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Stack(
            children: [
              if (provider.book?.coverImageUrl != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.asset(
                      "assets/images/thumbnails/${provider.book!.coverImageUrl!}",
                      fit: BoxFit.cover,
                      height: 260,
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.background,
                      colorScheme.background.withOpacity(0.92),
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
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.book == null
                        ? Center(child: Text(lang.t('book_not_found')))
                        : _Body(book: provider.book!, lang: lang),
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
        color: Theme.of(context).colorScheme.background.withOpacity(0.92),
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
  const _Body({required this.book, required this.lang});

  final Book book;
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                            color: colorScheme.surfaceVariant,
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
                    onPressed: () {},
                    icon: const Icon(Icons.library_add_outlined),
                    label: Text(lang.t('add_to_shelf')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(lang.t('read_from_first')),
                  ),
                ),
              ],
            ),
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
            _ChapterHeader(lang: lang),
            const SizedBox(height: 8),
            _ChaptersList(),
          ],
        ),
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.lang});
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookDetailsProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              lang.t('chapters'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${provider.chapters.length} chương',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          hint: const Text('Chọn chương'),
          items: provider.chapters
              .asMap()
              .entries
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e.key,
                  child: Text('Chương ${e.key + 1}'),
                ),
              )
              .toList(),
          onChanged: (idx) {
            // TODO: jump to selected chapter / open reader
          },
        ),
      ],
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
            // TODO: navigate to reader
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
