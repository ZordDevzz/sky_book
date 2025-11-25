import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/chapter.dart';
import 'package:sky_book/repositories/author_repository.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/repositories/tag_repository.dart';
import 'package:sky_book/screens/reader/reader_provider.dart';
import 'package:sky_book/services/database_service.dart';
import 'package:sky_book/services/theme_provider.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
    this.chapterId,
    this.book,
    this.chapters,
    this.currentChapter,
  }) : assert(chapterId != null ||
            (book != null && chapters != null && currentChapter != null));

  final String? chapterId;
  final Book? book;
  final List<Chapter>? chapters;
  final Chapter? currentChapter;

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final chapterRepository = ChapterRepository(dbService: dbService);
    final bookRepository = BookRepository(
      dbService: dbService,
      authorRepository: AuthorRepository(dbService: dbService),
      tagRepository: TagRepository(dbService: dbService),
    );

    return ChangeNotifierProvider(
      create: (context) {
        if (book != null && chapters != null && currentChapter != null) {
          return ReaderProvider.fromData(
            chapterRepository,
            bookRepository,
            book: book!,
            chapters: chapters!,
            currentChapter: currentChapter!,
          );
        }
        return ReaderProvider(
          chapterRepository,
          bookRepository,
          chapterId!,
        );
      },
      child: const _ReaderView(),
    );
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView();

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  bool _isNavBarVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    final provider = Provider.of<ReaderProvider>(context, listen: false);
    provider.addListener(() {
      if (!provider.isLoading && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _scrollListener() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_isFabVisible) setState(() => _isFabVisible = false);
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (direction == ScrollDirection.forward) {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
    }

    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _showSettingsMenu(BuildContext context, ReaderProvider readerProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make it transparent
      builder: (_) => ChangeNotifierProvider.value(
        value: readerProvider,
        child: const _SettingsMenu(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReaderProvider>(context);

    return Selector<ThemeProvider, ThemeMode>(
      selector: (_, themeProvider) => themeProvider.themeMode,
      builder: (context, themeMode, _) {
        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: provider.backgroundColor ?? colorScheme.surface,
          body: provider.isLoading && provider.currentChapter == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      title: Text(
                        provider.currentBook?.title ?? 'Loading...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(20),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            provider.currentChapter?.title ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: (provider.textColor ??
                                      Theme.of(context).colorScheme.onSurface)
                                  .withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      backgroundColor: (provider.backgroundColor ??
                              Theme.of(context).colorScheme.surface)
                          .withOpacity(0.9),
                      pinned: true,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 16, 16, 120), // Padding at bottom
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Selector<ReaderProvider, double>(
                                selector: (_, readerProvider) =>
                                    readerProvider.fontSize,
                                builder: (context, fontSize, __) {
                                  return Text(
                                    provider.currentChapter?.content ??
                                        'Chapter content not found.',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      height: 1.6,
                                      color: provider.textColor ??
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
          floatingActionButton: AnimatedOpacity(
            opacity: _isFabVisible ? 1.0 : 0.2,
            duration: const Duration(milliseconds: 250),
            child: FloatingActionButton(
              onPressed: () => _showSettingsMenu(context, provider),
              child: const Icon(Icons.settings),
            ),
          ),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isNavBarVisible || _isFabVisible ? 80 : 0,
            child: _ChapterNavigation(
              onNext: provider.isLastChapter ? null : provider.goToNextChapter,
              onPrevious: provider.isFirstChapter
                  ? null
                  : provider.goToPreviousChapter,
            ),
          ),
        );
      },
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu();

  void _showColorPicker(
    BuildContext context,
    Color initialColor,
    Function(Color) onColorChanged, {
    VoidCallback? onDefault,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          if (onDefault != null)
            TextButton(
              child: const Text('Default'),
              onPressed: () {
                onDefault();
                Navigator.of(context).pop();
              },
            ),
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerProvider = Provider.of<ReaderProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Font Size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Font Size'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: readerProvider.decreaseFontSize,
                    ),
                    Text(readerProvider.fontSize.toStringAsFixed(0)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: readerProvider.increaseFontSize,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            // Background Color
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.format_color_fill),
              title: const Text('Background Color'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showColorPicker(
                context,
                readerProvider.backgroundColor ?? colorScheme.surface,
                readerProvider.changeBackgroundColor,
                onDefault: () => readerProvider.changeBackgroundColor(null),
              ),
            ),
            // Text Color
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.format_color_text),
              title: const Text('Text Color'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showColorPicker(
                context,
                readerProvider.textColor ?? colorScheme.onSurface,
                readerProvider.changeTextColor,
                onDefault: () => readerProvider.changeTextColor(null),
              ),
            ),
            const Divider(),
            // Dark Mode
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark Mode'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (_) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _ChapterNavigation extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _ChapterNavigation({required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.arrow_back_ios),
            label: const Text('Previous'),
          ),
          TextButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_ios),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}