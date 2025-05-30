import 'package:flutter/material.dart';
import 'user_model.dart';
import 'user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService service;
  final Map<String, UserProfile> _userCache = {};

  UserProvider({required this.service});

  UserProfile? getCurrentUser(String userId) => _userCache[userId];

  Future<void> loadUser(String userId) async {
    if (_userCache.containsKey(userId)) return;
    final user = await UserService.getUserProfile(userId);
    if (user != null) {
      _userCache[userId] = user;
      notifyListeners();
    }
  }

  Future<UserProfile?> getUser(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    final user = await UserService.getUserProfile(userId);
    if (user != null) {
      _userCache[userId] = user;
      notifyListeners();
    }
    return user;
  }

  Future<void> updateUser(UserProfile user) async {
    await UserService.updateUser(user);
    _userCache[user.id] = user;
    notifyListeners();
  }
}
