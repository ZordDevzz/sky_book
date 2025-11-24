import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  String name = 'Khách';
  String userId = '';
  String passwdHash = '';
  String? pfpUrl;
  DateTime? createdAt;


  ProfileProvider() {
    _load();
  }

  Future<void> _load() async {
  }

  Future<void> saveProfile({required String username, String? pfpUrl}) async {
  }

  void setAvatar(String? url) {
    pfpUrl = url;
    notifyListeners();
  }
}
