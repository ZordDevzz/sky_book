import 'package:uuid/uuid.dart';

class User {
  String userId;
  String username;
  String passwdHash;
  String? pfpUrl;
  DateTime? createdAt;

  User({
    required this.userId,
    required this.username,
    required this.passwdHash,
    this.pfpUrl,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      passwdHash: json['passwd_hash'] as String,
      pfpUrl: json['pfp_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'passwd_hash': passwdHash,
      'pfp_url': pfpUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}