class Tag {
  int tagId;
  String name;

  Tag({
    required this.tagId,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagId: json['tag_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'name': name,
    };
  }
}