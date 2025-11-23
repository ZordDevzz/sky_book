class Shelf {
  final String userId;
  final String bookId;
  final String? lastReadChapterId;
  final DateTime lastReadDate;
  final bool isArchived;

  Shelf({
    required this.userId,
    required this.bookId,
    this.lastReadChapterId,
    required this.lastReadDate,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'BookId': bookId,
      'LastReadChapterId': lastReadChapterId,
      'LastReadDate': lastReadDate.toIso8601String(),
      'IsArchived': isArchived ? 1 : 0,
    };
  }

  factory Shelf.fromMap(Map<String, dynamic> map) {
    return Shelf(
      userId: map['UserId'],
      bookId: map['BookId'],
      lastReadChapterId: map['LastReadChapterId'],
      lastReadDate: DateTime.parse(map['LastReadDate']),
      isArchived: map['IsArchived'] == 1,
    );
  }
}
