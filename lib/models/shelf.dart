class Shelf {
  String userId;
  String bookId;
  String? lastReadChapterId;
  DateTime? lastReadDate;
  bool? isArchived;

  Shelf({
    required this.userId,
    required this.bookId,
    this.lastReadChapterId,
    this.lastReadDate,
    this.isArchived,
  });

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      lastReadChapterId: json['last_read_chapter_id'] as String?,
      lastReadDate: json['last_read_date'] != null
          ? DateTime.parse(json['last_read_date'] as String)
          : null,
      isArchived: json['is_archived'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'book_id': bookId,
      'last_read_chapter_id': lastReadChapterId,
      'last_read_date': lastReadDate?.toIso8601String(),
      'is_archived': isArchived,
    };
  }
}
