class Author {
  final String authorId;
  final String name;

  Author({
    required this.authorId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'AuthorId': authorId,
      'Name': name,
    };
  }

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      authorId: map['AuthorId'],
      name: map['Name'],
    );
  }
}
