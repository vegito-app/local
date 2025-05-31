import 'dart:convert';

import 'package:car2go/config.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class VegetableService {
  static Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  static Future<List<Vegetable>> listVegetables() async {
    final response = await http.get(
      Uri.parse('${Config.backendUrl}/api/vegetables'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
      return decoded
          .map((v) => Vegetable.fromJson(v as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch vegetables');
    }
  }

  static Future<Vegetable> getVegetable(String id) async {
    final response = await http.get(
      Uri.parse('${Config.backendUrl}/api/vegetables/$id'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      return Vegetable.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Vegetable not found');
    }
  }

  static Future<Vegetable> createVegetable(Vegetable vegetable) async {
    final url = '${Config.backendUrl}/api/vegetables';
    final response = await http.post(
      Uri.parse(url),
      headers: await _authHeaders(),
      body: json.encode(vegetable.toJson()),
    );
    if (response.statusCode == 201) {
      return Vegetable.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create vegetable');
    }
  }

  static Future<void> updateVegetable(String id, Vegetable vegetable) async {
    final response = await http.put(
      Uri.parse('${Config.backendUrl}/api/vegetables/$id'),
      headers: await _authHeaders(),
      body: json.encode(vegetable.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vegetable');
    }
  }

  static Future<void> deleteVegetable(String id) async {
    final response = await http.delete(
      Uri.parse('${Config.backendUrl}/api/vegetables/$id'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete vegetable');
    }
  }
}
