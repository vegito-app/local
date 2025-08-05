import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;

class WalletStorage {
  static const _privateKeyKey = 'private_key';
  static const _recoveryKeyKey = 'recovery_key';

  static const _storage = FlutterSecureStorage();
  // Récupération sécurisée ou création de la clé privée
  static Future<String?> getPrivateKey() async {
    return await _storage.read(key: _privateKeyKey);
  }

  static Future<void> storePrivateKey(String privateKey) async {
    await _storage.write(key: _privateKeyKey, value: privateKey);
  }

  static Future<void> storeRecoveryKeyLocally(String newKey) async {
    await _storage.write(key: _recoveryKeyKey, value: newKey);
  }

  static Future<String?> getLocallyStoredRecoveryKey() async {
    return await _storage.read(key: _recoveryKeyKey);
  }
}
