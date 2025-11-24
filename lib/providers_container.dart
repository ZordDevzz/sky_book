import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sky_book/repositories/author_repository.dart';
import 'package:sky_book/repositories/book_repository.dart';
import 'package:sky_book/repositories/tag_repository.dart';
import 'package:sky_book/services/database_service.dart';
import 'package:sky_book/services/language_provider.dart';
import 'package:sky_book/services/theme_provider.dart';
import 'package:sky_book/screens/discover/discover_provider.dart';
import 'package:sky_book/screens/home/home_provider.dart';
import 'package:sky_book/screens/leaderboard/leaderboard_provider.dart';
import 'package:sky_book/screens/profile/profile_provider.dart';
import 'package:sky_book/screens/shelf/shelf_provider.dart';

List<SingleChildWidget> providers = [
  Provider<DatabaseService>(
    create: (_) => DatabaseService(),
    dispose: (_, dbService) => dbService.dispose(),
  ),
  Provider<AuthorRepository>(
    create: (context) => AuthorRepository(
      dbService: Provider.of<DatabaseService>(context, listen: false),
    ),
  ),
  Provider<TagRepository>(
    create: (context) => TagRepository(
      dbService: Provider.of<DatabaseService>(context, listen: false),
    ),
  ),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => LanguageProvider()),
  ChangeNotifierProvider(create: (_) => ShelfProvider()),
  ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
  ChangeNotifierProvider(create: (_) => DiscoverProvider()),
  ChangeNotifierProvider(create: (_) => ProfileProvider()),
  ProxyProvider<DatabaseService, BookRepository>(
    update: (context, dbService, _) => BookRepository(
      dbService: dbService,
      authorRepository: Provider.of<AuthorRepository>(context, listen: false),
      tagRepository: Provider.of<TagRepository>(context, listen: false),
    ),
  ),
  ChangeNotifierProxyProvider<BookRepository, HomeProvider>(
    create: (context) =>
        HomeProvider(Provider.of<BookRepository>(context, listen: false)),
    update: (context, bookRepo, previous) => HomeProvider(bookRepo),
  ),
];
