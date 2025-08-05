import 'package:flutter/material.dart';
import 'user_model.dart';
import 'user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService service;
  final Map<String, UserProfile> _userCache = {};

  UserProvider({UserService? service}) : service = service ?? UserService();

  UserProfile? getCurrentUser(String userId) => _userCache[userId];

  Future<void> loadUser(String userId) async {
    if (_userCache.containsKey(userId)) return;
    final user = await service.getUserProfile(userId);
    _userCache[userId] = user;
    notifyListeners();
  }

  Future<UserProfile?> getUser(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    final user = await service.getUserProfile(userId);
    _userCache[userId] = user;
    notifyListeners();
    return user;
  }

  Future<void> updateUser(UserProfile user) async {
    await service.updateUser(user);
    _userCache[user.id] = user;
    notifyListeners();
  }

  /// Met à jour l'adresse et/ou la localisation du profil utilisateur
  Future<void> updateUserAddress(
      String userId, Map<String, dynamic> updates) async {
    await service.updateUserById(userId, updates);
    // Recharge le user après update pour mettre à jour les infos locales
    final user = await service.getUserProfile(userId);
    _userCache[userId] = user;
    notifyListeners();
  }

  /// Met à jour le nom d'affichage du profil utilisateur
  Future<void> updateDisplayName(String userId, String displayName) async {
    await service.updateUserById(userId, {'displayName': displayName});
    // Recharge le user après update pour mettre à jour les infos locales
    final user = await service.getUserProfile(userId);
    _userCache[userId] = user;
    notifyListeners();
  }

  Future<void> setUserReputationOptIn(String userId, bool enabled) {
    return service.updateUserById(userId, {'reputationOptIn': enabled});
  }
}
