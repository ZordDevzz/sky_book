class Tag {
  final int tagId;
  final String name;

  Tag({
    required this.tagId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'TagId': tagId,
      'Name': name,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      tagId: map['TagId'],
      name: map['Name'],
    );
  }
}
