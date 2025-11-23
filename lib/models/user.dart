class User {
  final String userId;
  final String username;
  final String passwdHash;
  final String? pfpUrl;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.username,
    required this.passwdHash,
    this.pfpUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'Username': username,
      'PasswdHash': passwdHash,
      'PfpUrl': pfpUrl,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['UserId'],
      username: map['Username'],
      passwdHash: map['PasswdHash'],
      pfpUrl: map['PfpUrl'],
      createdAt: DateTime.parse(map['CreatedAt']),
    );
  }
}
