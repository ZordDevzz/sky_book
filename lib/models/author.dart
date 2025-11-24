import 'package:uuid/uuid.dart';

class Author {
  String authorId;
  String name;

  Author({
    required this.authorId,
    required this.name,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      authorId: json['author_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author_id': authorId,
      'name': name,
    };
  }
}