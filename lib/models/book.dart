import 'package:sky_book/models/author.dart';
import 'package:sky_book/models/tag.dart';

class Book {
  String bookId;
  String title;
  String authorId; // Keep for database interaction if needed
  Author? author; // Embedded Author object
  String? description;
  String? coverImageUrl;
  DateTime? releaseDate;
  String? status; // 'Ongoing', 'Completed', 'Halt'
  double? rating;
  int viewCountTotal = 0;
  int viewCountMonthly = 0;
  int viewCountWeekly = 0;
  List<Tag> tags;

  Book({
    required this.bookId,
    required this.title,
    required this.authorId,
    this.author,
    this.description,
    this.coverImageUrl,
    this.releaseDate,
    this.status,
    this.rating,
    this.viewCountTotal = 0,
    this.viewCountMonthly = 0,
    this.viewCountWeekly = 0,
    this.tags = const [],
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      authorId: json['author_id'] as String,
      author: json['author'] != null
          ? Author.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      status: json['status'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      viewCountTotal: json['view_count_total'] as int,
      viewCountMonthly: json['view_count_monthly'] as int,
      viewCountWeekly: json['view_count_weekly'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'title': title,
      'author_id': authorId,
      'author': author?.toJson(),
      'description': description,
      'cover_image_url': coverImageUrl,
      'release_date': releaseDate
          ?.toIso8601String()
          .split('T')
          .first, // DATE only
      'status': status,
      'rating': rating,
      'view_count_total': viewCountTotal,
      'view_count_monthly': viewCountMonthly,
      'view_count_weekly': viewCountWeekly,
    };
  }
}
