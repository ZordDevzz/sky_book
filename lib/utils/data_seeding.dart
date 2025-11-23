import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/chapter.dart';

Future<void> seedInitialData(Database db) async {
  var uuid = Uuid();

  // 1. Create a User
  String userId = uuid.v4();
  User user = User(
    userId: userId,
    username: 'demo_user',
    passwdHash: 'hashed_password', // In a real app, hash this properly
    createdAt: DateTime.now(),
  );
  await db.insert('User', user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);

  // 2. Create Authors
  String authorId1 = uuid.v4();
  String authorId2 = uuid.v4();
  Author author1 = Author(authorId: authorId1, name: 'First Author');
  Author author2 = Author(authorId: authorId2, name: 'Second Author');
  await db.insert('Author', author1.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  await db.insert('Author', author2.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);

  // 3. Create Books
  String bookId1 = uuid.v4();
  String bookId2 = uuid.v4();
  String bookId3 = uuid.v4();

  Book book1 = Book(
    bookId: bookId1,
    title: 'The First Book',
    authorId: authorId1,
    description: 'This is the first book.',
    status: 'Ongoing',
    releaseDate: DateTime.now(),
  );

  Book book2 = Book(
    bookId: bookId2,
    title: 'The Second Book',
    authorId: authorId2,
    description: 'This is the second book.',
    status: 'Completed',
    releaseDate: DateTime.now(),
  );
  
  Book book3 = Book(
    bookId: bookId3,
    title: 'The Third Book',
    authorId: authorId1,
    description: 'This is the third book.',
    status: 'Halt',
    releaseDate: DateTime.now(),
  );

  await db.insert('Book', book1.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  await db.insert('Book', book2.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  await db.insert('Book', book3.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);

  // 4. Create Chapters for each book
  for (var bookId in [bookId1, bookId2, bookId3]) {
    for (int i = 1; i <= 5; i++) {
      Chapter chapter = Chapter(
        chapterId: uuid.v4(),
        bookId: bookId,
        title: 'Chapter $i',
        content: 'This is the content of chapter $i of book $bookId.',
        chapterIndex: i.toDouble(),
        publishDate: DateTime.now(),
      );
      await db.insert('Chapter', chapter.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
