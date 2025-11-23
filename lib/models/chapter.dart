class Chapter {
  final String chapterId;
  final String bookId;
  final String title;
  final String content;
  final double chapterIndex;
  final int? wordCount;
  final DateTime publishDate;

  Chapter({
    required this.chapterId,
    required this.bookId,
    required this.title,
    required this.content,
    required this.chapterIndex,
    this.wordCount,
    required this.publishDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'ChapterId': chapterId,
      'BookId': bookId,
      'Title': title,
      'Content': content,
      'ChapterIndex': chapterIndex,
      'WordCount': wordCount,
      'PublishDate': publishDate.toIso8601String(),
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      chapterId: map['ChapterId'],
      bookId: map['BookId'],
      title: map['Title'],
      content: map['Content'],
      chapterIndex: map['ChapterIndex'],
      wordCount: map['WordCount'],
      publishDate: DateTime.parse(map['PublishDate']),
    );
  }
}
