import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/screens/book_details/book_details_screen.dart';
import 'package:sky_book/screens/discover/discover_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DiscoverProvider>(context, listen: false);
    _searchController = TextEditingController(text: provider.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Consumer<DiscoverProvider>(
          builder: (context, provider, _) {
            final colorScheme = Theme.of(context).colorScheme;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _DiscoverHeader(
                    lang: lang,
                    controller: _searchController,
                    onQueryChanged: provider.updateQuery,
                    onClear: () {
                      _searchController.clear();
                      provider.updateQuery('');
                    },
                    sort: provider.sort,
                    onSortChanged: provider.setSort,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(height: 8),
                _TagBar(
                  lang: lang,
                  provider: provider,
                  colorScheme: colorScheme,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.fetchBooks,
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.books.isEmpty
                        ? Center(child: Text(lang.t('no_results')))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: provider.books.length,
                            itemBuilder: (context, index) {
                              final book = provider.books[index];
                              return _BookTile(
                                lang: lang,
                                book: book,
                                colorScheme: colorScheme,
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({
    required this.lang,
    required this.controller,
    required this.onQueryChanged,
    required this.onClear,
    required this.sort,
    required this.onSortChanged,
    required this.colorScheme,
  });

  final LanguageProvider lang;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final DiscoverSort sort;
  final ValueChanged<DiscoverSort> onSortChanged;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.16),
            colorScheme.secondary.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('discover'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            lang.t('discover_subtitle'),
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              return TextField(
                controller: controller,
                onChanged: onQueryChanged,
                decoration: InputDecoration(
                  hintText: lang.t('search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClear,
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                lang.t('sort_by'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 8,
                children: DiscoverSort.values.map((s) {
                  final selected = s == sort;
                  final label = switch (s) {
                    DiscoverSort.newest => lang.t('sort_newest'),
                    DiscoverSort.rating => lang.t('sort_rating'),
                  };
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => onSortChanged(s),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagBar extends StatelessWidget {
  const _TagBar({
    required this.lang,
    required this.provider,
    required this.colorScheme,
  });

  final LanguageProvider lang;
  final DiscoverProvider provider;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final tags = provider.availableTags;
    if (tags.isEmpty) return const SizedBox(height: 12);
    return Container(
      height: 72,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(5, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              lang.t('filter_tags'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = tags[index];
                final selected = provider.selectedTag?.tagId == tag.tagId;
                return FilterChip(
                  label: Text(tag.name),
                  selected: selected,
                  onSelected: (_) => provider.toggleTag(tag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({
    required this.lang,
    required this.book,
    required this.colorScheme,
  });

  final LanguageProvider lang;
  final Book book;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(bookId: book.bookId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 96,
                  child: book.coverImageUrl != null
                      ? Image.asset(
                          "assets/images/thumbnails/${book.coverImageUrl!}",
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colorScheme.surfaceVariant,
                          child: const Icon(Icons.book),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.author?.name ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _pill(
                          Icons.visibility,
                          '${book.viewCountWeekly} ${lang.t('views_week')}',
                          colorScheme,
                        ),
                        _pill(
                          Icons.star_rate_rounded,
                          '${(book.rating ?? 0).toStringAsFixed(1)}/5',
                          colorScheme,
                        ),
                        if (book.tags.isNotEmpty)
                          _pill(
                            Icons.label_outline,
                            book.tags.first.name,
                            colorScheme,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
