class Shelf {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final List<String> genres;
  final int totalChapters;
  final double rating;
  final int views;
  final DateTime publishedDate;
  final bool isCompleted;

  Shelf({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.genres,
    required this.totalChapters,
    this.rating = 0.0,
    this.views = 0,
    required this.publishedDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'description': description,
      'genres': genres,
      'totalChapters': totalChapters,
      'rating': rating,
      'views': views,
      'publishedDate': publishedDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      coverUrl: json['coverUrl'],
      description: json['description'],
      genres: List<String>.from(json['genres']),
      totalChapters: json['totalChapters'],
      rating: json['rating']?.toDouble() ?? 0.0,
      views: json['views'] ?? 0,
      publishedDate: DateTime.parse(json['publishedDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
