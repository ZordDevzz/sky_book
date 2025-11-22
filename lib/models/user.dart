class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final DateTime memberSince;
  final int storiesRead;
  final int readingStreak;
  final int totalReadingTime; // in minutes
  final int followersCount;
  final int followingCount;
  final List<String> badges;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    required this.memberSince,
    this.storiesRead = 0,
    this.readingStreak = 0,
    this.totalReadingTime = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.badges = const [],
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    DateTime? memberSince,
    int? storiesRead,
    int? readingStreak,
    int? totalReadingTime,
    int? followersCount,
    int? followingCount,
    List<String>? badges,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
      storiesRead: storiesRead ?? this.storiesRead,
      readingStreak: readingStreak ?? this.readingStreak,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'memberSince': memberSince.toIso8601String(),
      'storiesRead': storiesRead,
      'readingStreak': readingStreak,
      'totalReadingTime': totalReadingTime,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'badges': badges,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      memberSince: DateTime.parse(json['memberSince']),
      storiesRead: json['storiesRead'] ?? 0,
      readingStreak: json['readingStreak'] ?? 0,
      totalReadingTime: json['totalReadingTime'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      badges: json['badges'] != null ? List<String>.from(json['badges']) : [],
    );
  }
}
