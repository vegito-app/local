import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

import 'user_model.dart';

const backendUrl = Config.backendUrl;

class UserService {
  static Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$backendUrl/api/users');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<List<UserProfile>> listUsers() async {
    final url = Uri.parse('$backendUrl/api/users');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération des utilisateurs');
    }

    final data = jsonDecode(response.body) as List;
    return data
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> updateUser(UserProfile user) async {
    await updateUserById(user.id, user.toMap());
  }

  static Future<void> updateUserById(
      String userId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$backendUrl/api/users/$userId');
    await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
  }

  static Future<UserProfile> getUserProfile(String userId) async {
    final url = Uri.parse('$backendUrl/api/users/$userId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération du profil utilisateur');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }
}
