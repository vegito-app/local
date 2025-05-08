// Fonction pour récupérer la recoveryKey depuis le backend
import 'dart:convert';
import 'package:car2go/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http show get, post;

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

// Rotation des clés

Future<String?> getRecoveryKeyVersion(String userId) async {
  final response = await http.post(
    Uri.parse("${Config.backendUrl}/user/get-recoverykey-version"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "userId": userId,
    }),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body["recoveryKey"] as String?;
  } else {
    throw Exception("Impossible de récupérer la version de la RecoveryKey");
  }
}

// Mise en place de la clé de récupération et recoveryKey
Future<String> postRecoveryKey(String recoveryKey) async {
  // Envoyer recoveryKey au backend pour stockage sécurisé
  final response = await http.post(
    Uri.parse("${Config.backendUrl}/user/store-recoverykey"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "userId": FirebaseAuth.instance.currentUser?.uid,
      "recoveryKey": recoveryKey
    }),
  );

  if (response.statusCode == 200) {
    return "RecoveryKey stockée avec succès dans le backend.";
  } else {
    throw Exception(
        "Échec de l'enregistrement de la RecoveryKey sur le serveur.");
  }
}
