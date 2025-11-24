import 'package:uuid/uuid.dart';

class Chapter {
  String chapterId;
  String bookId;
  String title;
  String content;
  double chapterIndex;
  int? wordCount;
  DateTime? publishDate;

  Chapter({
    required this.chapterId,
    required this.bookId,
    required this.title,
    required this.content,
    required this.chapterIndex,
    this.wordCount,
    this.publishDate,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapter_id'] as String,
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      chapterIndex: (json['chapter_index'] as num).toDouble(),
      wordCount: json['word_count'] as int?,
      publishDate: json['publish_date'] != null
          ? DateTime.parse(json['publish_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'book_id': bookId,
      'title': title,
      'content': content,
      'chapter_index': chapterIndex,
      'word_count': wordCount,
      'publish_date': publishDate?.toIso8601String(),
    };
  }
}