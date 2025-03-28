import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletService {
  static const _storage = FlutterSecureStorage();
  static const _privateKeyKey = 'private_key';
  static const _recoveryKeyKey = 'recovery_key';
  static final _firestore = FirebaseFirestore.instance;

  // Générer une clé aléatoire (32 bytes encodés en Base64)
  static String _generateKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  // Fonction XOR entre deux listes d'octets
  static List<int> _xorBytes(List<int> a, List<int> b) {
    return List<int>.generate(a.length, (i) => a[i] ^ b[i]);
  }

  // Générer ou récupérer la clé privée
  static Future<Map<String, String>> getKeys(String userId) async {
    String? privateKey = await _storage.read(key: _privateKeyKey);
    String? recoveryKey = await _storage.read(key: _recoveryKeyKey);

    if (privateKey == null) {
      // Vérifier si une clé XORée existe dans Firestore
      DocumentSnapshot snapshot =
          await _firestore.collection('wallets').doc(userId).get();
      if (snapshot.exists) {
        // Impossible de récupérer la clé privée sans la recovery key
        throw Exception(
            "Impossible de restaurer votre wallet sans la clé de récupération !");
      } else {
        // Générer nouvelle clé privée et recovery key
        privateKey = _generateKey();
        recoveryKey = _generateKey();

        // Appliquer XOR et stocker uniquement la version sécurisée sur Firestore
        List<int> privateKeyBytes = base64Decode(privateKey);
        List<int> recoveryBytes = base64Decode(recoveryKey);
        List<int> xorBytes = _xorBytes(privateKeyBytes, recoveryBytes);

        await _storage.write(key: _privateKeyKey, value: privateKey);
        await _storage.write(key: _recoveryKeyKey, value: recoveryKey);

        await _firestore.collection('wallets').doc(userId).set({
          'xorKey': base64Encode(
              xorBytes), // Seule cette partie est stockée sur Firestore
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    if (recoveryKey != null) {
      return {'privateKey': privateKey, 'recoveryKey': recoveryKey};
    }
    return {'privateKey': privateKey};
  }
}
