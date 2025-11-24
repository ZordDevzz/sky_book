import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/screens/home/home_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          _TopBar(lang: lang),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchBooks(),
              child: ListView(
                children: [
                  _FeaturedSection(
                    lang: lang,
                    isLoading: provider.isLoading,
                    books: provider.featuredBooks,
                    pageController: _pageController,
                    currentPage: _currentPage,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                  ),
                  Divider(color: Colors.grey.withAlpha(100), thickness: 1.0),
                  _NewReleasesSection(
                    lang: lang,
                    isLoading: provider.isLoading,
                    books: provider.newReleaseBooks,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.lang});
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({
    required this.lang,
    required this.isLoading,
    required this.books,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  final LanguageProvider lang;
  final bool isLoading;
  final List<Book> books;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.12),
            colorScheme.secondary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('featured_books'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.t('featured_muted'),
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${books.length}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : books.isEmpty
                ? Center(child: Text(lang.t('no_books_found')))
                : PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isActive = index == currentPage;
                      return _FeaturedCard(
                        book: book,
                        isActive: isActive,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
          ),
          if (books.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  books.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: i == currentPage ? 20 : 8,
                    decoration: BoxDecoration(
                      color: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.book,
    required this.isActive,
    required this.colorScheme,
  });

  final Book book;
  final bool isActive;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final scale = isActive ? 1.0 : 0.92;
    final elevation = isActive ? 10.0 : 2.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 220),
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // TODO: navigate to book details
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (book.coverImageUrl != null)
                Image.asset(
                  "assets/images/thumbnails/${book.coverImageUrl!}",
                  fit: BoxFit.cover,
                )
              else
                Container(
                  color: colorScheme.surface,
                  child: const Icon(Icons.book, size: 48),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            book.author?.name ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Chip(
                          icon: Icons.visibility,
                          label: '${book.viewCountWeekly} lượt / tuần',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          icon: Icons.star_rate_rounded,
                          label:
                              '${(book.rating ?? 0).toStringAsFixed(1)} / 5.0',
                          color: Colors.white,
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
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
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

class _NewReleasesSection extends StatelessWidget {
  const _NewReleasesSection({
    required this.lang,
    required this.isLoading,
    required this.books,
  });

  final LanguageProvider lang;
  final bool isLoading;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            lang.t('new_releases'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (books.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(lang.t('no_books_found'))),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 88,
                        child: book.coverImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  "assets/images/thumbnails/${book.coverImageUrl!}",
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.book),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 14.0,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4.0),
                                Expanded(
                                  child: Text(
                                    book.author?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14.0,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  book.releaseDate != null
                                      ? "${book.releaseDate!.year}-${book.releaseDate!.month.toString().padLeft(2, '0')}-${book.releaseDate!.day.toString().padLeft(2, '0')}"
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
