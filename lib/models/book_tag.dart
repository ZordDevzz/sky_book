class BookTag {
  final String bookId;
  final int tagId;

  BookTag({
    required this.bookId,
    required this.tagId,
  });

  Map<String, dynamic> toMap() {
    return {
      'BookId': bookId,
      'TagId': tagId,
    };
  }

  factory BookTag.fromMap(Map<String, dynamic> map) {
    return BookTag(
      bookId: map['BookId'],
      tagId: map['TagId'],
    );
  }
}
