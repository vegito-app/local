import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'dart:convert';

class WalletService {
  static const _storage = FlutterSecureStorage();
  static const _privateKeyKey = 'private_key';

  // Générer une nouvelle clé privée
  static String _generatePrivateKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  // Récupérer la clé privée stockée ou en générer une nouvelle
  static Future<String> getPrivateKey() async {
    String? privateKey = await _storage.read(key: _privateKeyKey);
    if (privateKey == null) {
      privateKey = _generatePrivateKey();
      await _storage.write(key: _privateKeyKey, value: privateKey);
    }
    return privateKey;
  }
}