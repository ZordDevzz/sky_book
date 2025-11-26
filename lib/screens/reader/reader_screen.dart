import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/models/book.dart';
import 'package:sky_book/models/chapter.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/chapter_repository.dart';
import 'package:sky_book/repositories/shelf_repository.dart';
import 'package:sky_book/screens/reader/reader_provider.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart'; // Import ShelfProvider
import 'package:sky_book/services/auth_provider.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
    this.chapterId,
    this.book,
    this.chapters,
    this.currentChapter,
  }) : assert(
          chapterId != null ||
              (book != null && chapters != null && currentChapter != null),
        );

  final String? chapterId;
  final Book? book;
  final List<Chapter>? chapters;
  final Chapter? currentChapter;

  @override
  Widget build(BuildContext context) {
    final defaultDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (context) {
        final chapterRepository =
            Provider.of<ChapterRepository>(context, listen: false);
        final bookRepository =
            Provider.of<BookRepository>(context, listen: false);
        final shelfRepository =
            Provider.of<ShelfRepository>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final shelfProvider = Provider.of<ShelfProvider>(context, listen: false); // Get ShelfProvider

        if (book != null && chapters != null && currentChapter != null) {
          return ReaderProvider.fromData(
            chapterRepository,
            bookRepository,
            shelfRepository,
            authProvider,
            shelfProvider, // Pass ShelfProvider
            book: book!,
            chapters: chapters!,
            currentChapter: currentChapter!,
            defaultDarkMode: defaultDarkMode,
          );
        }
        return ReaderProvider(
          chapterRepository,
          bookRepository,
          shelfRepository,
          authProvider,
          shelfProvider, // Pass ShelfProvider
          chapterId!,
          defaultDarkMode: defaultDarkMode,
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
  bool _showControlsOverlay = true;
  bool _settingsOpen = false;

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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showControlsOverlay = false);
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
    setState(() {
      _settingsOpen = true;
      _showControlsOverlay = false;
      _isFabVisible = false;
      _isNavBarVisible = false;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make it transparent
      builder: (_) => ChangeNotifierProvider.value(
        value: readerProvider,
        child: const _SettingsMenu(),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _settingsOpen = false;
          _showControlsOverlay = true;
          _isFabVisible = true;
          _isNavBarVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReaderProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = provider.readerDarkMode
        ? (provider.backgroundColor ?? const Color(0xFF0F141A))
        : (provider.backgroundColor ?? colorScheme.surface);
    final textColor = provider.readerDarkMode
        ? (provider.textColor ?? Colors.white)
        : (provider.textColor ?? colorScheme.onSurface);
    return Scaffold(
      backgroundColor: bgColor,
      body: provider.isLoading && provider.currentChapter == null
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _showControlsOverlay = !_showControlsOverlay;
                _isFabVisible = _showControlsOverlay;
                _isNavBarVisible = _showControlsOverlay;
              }),
              child: Stack(
                children: [
                  CustomScrollView(
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
                          preferredSize: const Size.fromHeight(40),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                provider.currentChapter?.title ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        backgroundColor: bgColor.withOpacity(0.94),
                        pinned: true,
                        floating: true,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 140),
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
                                        height: 1.75,
                                        color: textColor,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (_showControlsOverlay && !_settingsOpen) ...[
                    Positioned(
                      bottom: 24,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () => _showSettingsMenu(context, provider),
                        child: const Icon(Icons.settings),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 16,
                      child: Row(
                        children: [
                          _CircleNavButton(
                            icon: Icons.arrow_back_ios_new,
                            onTap: provider.isFirstChapter
                                ? null
                                : provider.goToPreviousChapter,
                          ),
                          const SizedBox(width: 10),
                          _CircleNavButton(
                            icon: Icons.arrow_forward_ios,
                            onTap: provider.isLastChapter
                                ? null
                                : provider.goToNextChapter,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tùy chỉnh',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cỡ chữ'),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.remove),
                        onPressed: readerProvider.decreaseFontSize,
                      ),
                      Text(readerProvider.fontSize.toStringAsFixed(0)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add),
                        onPressed: readerProvider.increaseFontSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.format_color_fill,
              title: 'Màu nền',
              onTap: () => _showColorPicker(
                context,
                readerProvider.backgroundColor ??
                    (readerProvider.readerDarkMode
                        ? const Color(0xFF0F141A)
                        : colorScheme.surface),
                readerProvider.changeBackgroundColor,
                onDefault: () => readerProvider.changeBackgroundColor(null),
              ),
            ),
            _SettingTile(
              icon: Icons.format_color_text,
              title: 'Màu chữ',
              onTap: () => _showColorPicker(
                context,
                readerProvider.textColor ??
                    (readerProvider.readerDarkMode
                        ? Colors.white
                        : colorScheme.onSurface),
                readerProvider.changeTextColor,
                onDefault: () => readerProvider.changeTextColor(null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        color: colorScheme.onSurface,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
