import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/user.dart';
import '../../repositories/user_repository.dart';

class ProfileProvider with ChangeNotifier {
  String name = 'Khách';
  String userId = '';
  String passwdHash = '';
  String? pfpUrl;
  DateTime? createdAt;

  final UserRepository _repo = UserRepository();

  ProfileProvider() {
    _load();
  }

  Future<void> _load() async {
    final user = await _repo.getFirstUser();
    if (user != null) {
      userId = user.userId;
      name = user.username;
      passwdHash = user.passwdHash;
      pfpUrl = user.pfpUrl;
      createdAt = user.createdAt;
      notifyListeners();
    }
  }

  Future<void> saveProfile({required String username, String? pfpUrl}) async {
    if (userId.isEmpty) {
      userId = const Uuid().v4();
      final newUser = User(
        userId: userId,
        username: username,
        passwdHash: '',
        pfpUrl: pfpUrl,
        createdAt: DateTime.now(),
      );
      await _repo.insertUser(newUser);
      name = username;
      this.pfpUrl = pfpUrl;
      notifyListeners();
    } else {
      final updated = User(
        userId: userId,
        username: username,
        passwdHash: passwdHash,
        pfpUrl: pfpUrl,
        createdAt: createdAt ?? DateTime.now(),
      );
      await _repo.updateUser(updated);
      name = username;
      this.pfpUrl = pfpUrl;
      notifyListeners();
    }
  }

  void setAvatar(String? url) {
    pfpUrl = url;
    notifyListeners();
  }
}
