import 'package:uuid/uuid.dart';

class BookTag {
  String bookId;
  int tagId;

  BookTag({
    required this.bookId,
    required this.tagId,
  });

  factory BookTag.fromJson(Map<String, dynamic> json) {
    return BookTag(
      bookId: json['book_id'] as String,
      tagId: json['tag_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'tag_id': tagId,
    };
  }
}