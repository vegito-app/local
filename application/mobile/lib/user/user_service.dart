import 'dart:convert';
import 'package:car2go/http/auth_headers.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'user_model.dart';

class UserService {
  final http.Client client;
  final String backendUrl;

  UserService({http.Client? client, String? backendUrl})
      : client = client ?? http.Client(),
        backendUrl = backendUrl ?? Config.backendUrl;

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$backendUrl/api/users');
    await client.post(
      url,
      headers: await authHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
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
