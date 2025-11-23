import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/tag.dart';
import '../models/book_tag.dart';

Future<void> seedInitialData(Database db) async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  final uuid = Uuid();

  // Clear existing data
  await db.transaction((txn) async {
    await txn.delete('User');
    await txn.delete('Author');
    await txn.delete('Book');
    await txn.delete('Chapter');
    await txn.delete('Tag');
    await txn.delete('Book_Tag');
  });

  // Seed Users
  final userFiles = manifestMap.keys
      .where((String key) => key.startsWith('assets/data/user/'))
      .toList();

  for (String userFile in userFiles) {
    final userJsonString = await rootBundle.loadString(userFile);
    final userJson = json.decode(userJsonString);
    final user = User.fromMap(userJson);
    await db.insert('User', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Seed Books, Authors, Tags, and Chapters
  final bookFiles = manifestMap.keys
      .where((String key) => key.startsWith('assets/data/book/'))
      .toList();

  for (String bookFile in bookFiles) {
    final bookJsonString = await rootBundle.loadString(bookFile);
    final bookJson = json.decode(bookJsonString);

    // Handle Author
    String authorName = bookJson['author'];
    List<Map<String, dynamic>> existingAuthors = await db.query(
      'Author',
      where: 'Name = ?',
      whereArgs: [authorName],
    );

    String authorId;
    if (existingAuthors.isNotEmpty) {
      authorId = existingAuthors.first['AuthorId'];
    } else {
      authorId = uuid.v4();
      Author newAuthor = Author(authorId: authorId, name: authorName);
      await db.insert('Author', newAuthor.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    // Generate BookId
    String bookId = uuid.v4();

    // Prepare book map for insertion
    final bookMap = {
      'BookId': bookId,
      'Title': bookJson['title'],
      'AuthorId': authorId,
      'Description': bookJson['description'],
      'CoverImageUrl': bookJson['coverImageUrl'],
      'ReleaseDate': bookJson['releaseDate'] != null
          ? DateTime.parse(bookJson['releaseDate']).toIso8601String().substring(0, 10)
          : null,
      'Status': bookJson['status'],
      'Rating': bookJson['rating'],
      'ViewCount_Total': bookJson['viewCountTotal'],
      'ViewCount_Monthly': bookJson['viewCountMonthly'],
      'ViewCount_Weekly': bookJson['viewCountWeekly'],
    };

    // Create and insert book
    final book = Book.fromMap(bookMap);
    await db.insert('Book', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Handle Tags
    List<String> tagNames = List<String>.from(bookJson['tags'] ?? []);
    for (String tagName in tagNames) {
      List<Map<String, dynamic>> existingTags = await db.query(
        'Tag',
        where: 'Name = ?',
        whereArgs: [tagName],
      );

      int tagId;
      if (existingTags.isNotEmpty) {
        tagId = existingTags.first['TagId'];
      } else {
        Tag newTag = Tag(tagId: 0, name: tagName); // Let SQLite auto-increment
        tagId = await db.insert('Tag', newTag.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      BookTag bookTag = BookTag(bookId: book.bookId, tagId: tagId);
      await db.insert('Book_Tag', bookTag.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Handle Chapters
    final chapters = bookJson['chapters'] as List;
    for (final chapterJson in chapters) {
      final chapterMap = {
        'ChapterId': uuid.v4(),
        'BookId': book.bookId,
        'Title': chapterJson['title'],
        'Content': chapterJson['content'],
        'ChapterIndex': chapterJson['chapterIndex'],
        'WordCount': (chapterJson['content'] as String)
            .split(RegExp(r'\s+'))
            .length,
        'PublishDate': chapterJson['publishDate'],
      };
      final chapter = Chapter.fromMap(chapterMap);
      await db.insert('Chapter', chapter.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}