// Fonction pour générer une clé privée aléatoire
import 'dart:convert';

// XOR entre deux clés
String xorKeys(String privateKey, String recoveryKey) {
  List<int> privateKeyBytes = base64Decode(privateKey);
  List<int> recoveryKeyBytes = base64Decode(recoveryKey);
  List<int> recoveryXorKeyBytes =
      List.generate(32, (i) => privateKeyBytes[i] ^ recoveryKeyBytes[i]);
  return base64Encode(recoveryXorKeyBytes);
}
