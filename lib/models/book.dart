
class Book {
  final String bookId;
  final String title;
  final String authorId;
  final String? description;
  final String? coverImageUrl;
  final String? releaseDate;
  final String status;
  final double rating;
  final int viewCountTotal;
  final int viewCountMonthly;
  final int viewCountWeekly;

  Book({
    required this.bookId,
    required this.title,
    required this.authorId,
    this.description,
    this.coverImageUrl,
    this.releaseDate,
    this.status = 'Ongoing',
    this.rating = 0.0,
    this.viewCountTotal = 0,
    this.viewCountMonthly = 0,
    this.viewCountWeekly = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'BookId': bookId,
      'Title': title,
      'AuthorId': authorId,
      'Description': description,
      'CoverImageUrl': coverImageUrl,
      'ReleaseDate': releaseDate,
      'Status': status,
      'Rating': rating,
      'ViewCount_Total': viewCountTotal,
      'ViewCount_Monthly': viewCountMonthly,
      'ViewCount_Weekly': viewCountWeekly,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      bookId: map['BookId'],
      title: map['Title'],
      authorId: map['AuthorId'],
      description: map['Description'],
      coverImageUrl: map['CoverImageUrl'],
      releaseDate: map['ReleaseDate'],
      status: map['Status'],
      rating: map['Rating'],
      viewCountTotal: map['ViewCount_Total'],
      viewCountMonthly: map['ViewCount_Monthly'],
      viewCountWeekly: map['ViewCount_Weekly'],
    );
  }
}
