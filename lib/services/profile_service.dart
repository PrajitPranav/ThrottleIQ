import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _userNameKey = 'user_name';
  static const String _avatarPathKey = 'avatar_path';

  String _userName = 'Prajit Pranav';
  String get userName => _userName;

  String? _avatarPath;
  String? get avatarPath => _avatarPath;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey) ?? 'Prajit Pranav';
    _avatarPath = prefs.getString(_avatarPathKey);
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    notifyListeners();
  }

  Future<void> updateAvatar(String? path) async {
    _avatarPath = path;
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_avatarPathKey);
    } else {
      await prefs.setString(_avatarPathKey, path);
    }
    notifyListeners();
  }
}
