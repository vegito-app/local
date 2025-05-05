import 'dart:convert';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:http/http.dart' as http show get, post;

import 'config.dart';

// Fonction pour générer une clé privée aléatoire
String generatePrivateKey() {
  final random = Random.secure();
  List<int> key = List.generate(32, (_) => random.nextInt(256));
  return base64Encode(key);
}

// XOR entre deux clés
String xorKeys(String privateKey, String recoveryKey) {
  List<int> privateKeyBytes = base64Decode(privateKey);
  List<int> recoveryKeyBytes = base64Decode(recoveryKey);
  List<int> recoveryXorKeyBytes =
      List.generate(32, (i) => privateKeyBytes[i] ^ recoveryKeyBytes[i]);
  return base64Encode(recoveryXorKeyBytes);
}

// Fonction pour récupérer la recoveryKey depuis le backend
Future<String> fetchRecoveryKeyXorComponent(String userId) async {
  final response = await http.get(
    Uri.parse("${Config.backendUrl}/user/generate-recoverykey"),
    headers: {"X-User-ID": userId},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String? rKey = data['recoveryKey'] as String?;
    if (rKey != null) {
      return rKey;
    }
    throw Exception("recoveryKey manquante dans la réponse du backend");
  } else {
    throw Exception("Impossible de récupérer la recoveryKey");
  }
}

class WalletService {
  static const _storage = FlutterSecureStorage();
  static const _privateKeyKey = 'private_key';
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
  static Future<String> generateRecoveryKey(String userId) async {
    String privateKey = await getPrivateKey();

    return await _setupRecovery(privateKey);
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

  // Mise en place de la clé de récupération et recoveryKey
  static Future<String> _setupRecovery(String privateKey) async {
    final recoveryKey = _generateRandomKey();
    final xorKey = _recoveryKeyXor(privateKey, recoveryKey);

    // Stocker recoveryKey en local
    await _storage.write(key: _recoveryKeyKey, value: recoveryKey);

    // Envoyer recoveryKey au backend pour stockage sécurisé
    final response = await http.post(
      Uri.parse("${Config.backendUrl}/user/store-recoverykey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": FirebaseAuth.instance.currentUser?.uid,
        "recoveryKey": xorKey
      }),
    );

    if (response.statusCode == 200) {
      return "RecoveryKey stockée avec succès dans le backend.";
    } else {
      throw Exception(
          "Échec de l'enregistrement de la RecoveryKey sur le serveur.");
    }
  }

  // Fonction de chiffrement XOR
  static String _recoveryKeyXor(String data, String key) {
    List<int> dataBytes = base64Decode(data);
    List<int> keyBytes = base64Decode(key);
    List<int> result = List.generate(
        dataBytes.length, (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    return base64Encode(result);
  }

  // Récupération de la clé de récupération
  static Future<String?> getRecoveryKey() async {
    return _storage.read(key: _recoveryKeyKey);
  }

  // Rotation des clés

  static Future<String?> getRecoveryKeyVersion(
      String userId, int version) async {
    final response = await http.post(
      Uri.parse("${Config.backendUrl}/user/get-recoverykey-version"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "version": version,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["recoveryKey"] as String?;
    } else {
      throw Exception(
          "Impossible de récupérer la version $version de la RecoveryKey");
    }
  }
}
