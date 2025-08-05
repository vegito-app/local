import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vegito/http/auth_headers.dart';

import '../config.dart';
import 'user_model.dart';

class UserService {
  final http.Client client;
  final String backendUrl;

  UserService({http.Client? client, String? backendUrl})
      : client = client ?? http.Client(),
        backendUrl = backendUrl ?? Config.backendUrl;

  Future<void> createUserFromFirebaseUser({
    String? name,
    required bool anonymous,
    required String firebaseUid,
    String? email,
    String? password,
  }) async {
    final url = Uri.parse('$backendUrl/api/users');
    final resp = await client.put(
      url,
      headers: await authHeaders(),
      body: jsonEncode({
        'anonymous': anonymous,
        // Si le nom n'est pas fourni, on utilise une valeur par défaut
        'name': name ?? 'Utilisateur Anonyme',
        // Si l'email n'est pas fourni, on utilise une valeur par défaut
        'email':
            email == null || email.isEmpty ? 'anonymous@vegito.app' : email,
        'password': password,
        'id': firebaseUid,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Échec lors de la création de l’utilisateur');
    }
  }

  Future<List<UserProfile>> listUsers() async {
    final url = Uri.parse('$backendUrl/api/users');
    final response = await client.get(url, headers: await authHeaders());

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération des utilisateurs');
    }

    final data = jsonDecode(response.body) as List;
    return data
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUser(UserProfile user) async {
    await updateUserById(user.id, user.toMap());
  }

  Future<void> updateUserById(
      String userId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$backendUrl/api/users/$userId');
    await client.put(
      url,
      headers: await authHeaders(),
      body: jsonEncode(updates),
    );
  }

  Future<UserProfile> getUserProfile(String userId) async {
    final url = Uri.parse('$backendUrl/api/user/$userId');
    final response = await client.get(url, headers: await authHeaders());
    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération du profil utilisateur');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }
}
