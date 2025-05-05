import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

// Fonction pour générer une clé privée aléatoire
String generatePrivateKey() {
  final random = Random.secure();
  List<int> key = List.generate(32, (_) => random.nextInt(256));
  return base64Encode(key);
}

// XOR entre deux clés
String xorKeys(String privateKey, String xorKey) {
  List<int> privateKeyBytes = base64Decode(privateKey);
  List<int> xorKeyBytes = base64Decode(xorKey);
  List<int> recoveryKeyBytes =
      List.generate(32, (i) => privateKeyBytes[i] ^ xorKeyBytes[i]);
  return base64Encode(recoveryKeyBytes);
}

// Fonction pour récupérer la xorkey depuis le backend
Future<String> fetchXorKey(String userId) async {
  final response = await http.get(
    Uri.parse("${Config.backendUrl}/generate-xorkey"),
    headers: {"X-User-ID": userId},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String? xKey = data['xorkey'] as String?;
    if (xKey != null) {
      return xKey;
    }
    throw Exception("xorkey manquante dans la réponse du backend");
  } else {
    throw Exception("Impossible de récupérer la xorkey");
  }
}

class WalletService {
  static const _storage = FlutterSecureStorage();
  static const _privateKeyKey = 'private_key';
  static const _xorKeyKey = 'xor_key';
  static const _recoveryKeyKey = 'recovery_key';

  // Génération d'une clé aléatoire
  static String _generateRandomKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  // Vérification si l'appareil est rooté/jailbreaké
  static Future<bool> _isCompromisedDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice == false;
  }

// Processus complet
  static Future<void> generateRecoveryKey(String userId) async {
    String privateKey = await getPrivateKey();

    _setupRecovery(privateKey);
  }

  // Récupération sécurisée ou création de la clé privée
  static Future<String> getPrivateKey() async {
    if (await _isCompromisedDevice()) {
      return "Appareil compromis, accès refusé.";
    }

    String? privateKey = await _storage.read(key: _privateKeyKey);
    if (privateKey == null) {
      privateKey = _generateRandomKey();
      await _storage.write(key: _privateKeyKey, value: privateKey);
      await _setupRecovery(privateKey);
    }
    return privateKey; // Toujours retourner la clé privée existante ou nouvellement créée
  }

  // Mise en place de la clé de récupération et XorKey
  static Future<String> _setupRecovery(String privateKey) async {
    final recoveryKey = _generateRandomKey();
    final xorKey = _xor(privateKey, recoveryKey);

    // Stocker recoveryKey en local
    await _storage.write(key: _recoveryKeyKey, value: recoveryKey);

    // Envoyer xorKey au backend pour stockage sécurisé
    final response = await http.post(
      Uri.parse("${Config.backendUrl}/store-xorkey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"userId": FirebaseAuth.instance.currentUser?.uid, "xorKey": xorKey}),
    );

    if (response.statusCode == 200) {
      return "XorKey stockée avec succès dans le backend.";
    } else {
      throw Exception("Échec de l'enregistrement de la XorKey sur le serveur.");
    }
  }

  // Fonction de chiffrement XOR
  static String _xor(String data, String key) {
    List<int> dataBytes = base64Decode(data);
    List<int> keyBytes = base64Decode(key);
    List<int> result = List.generate(
        dataBytes.length, (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    return base64Encode(result);
  }

  // Récupération de la clé de récupération
  static Future<String?> getRecoveryKey() async {
    return await _storage.read(key: _recoveryKeyKey);
  }

  // Rotation des clés
  static Future<String> rotateKeys() async {
    final privateKey = await getPrivateKey();
    if (privateKey != null) {
      return await _setupRecovery(privateKey);
    }
    return "Échec de la rotation des clés.";
  }
}
