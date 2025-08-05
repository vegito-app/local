import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, String>> authHeaders() async {
  final user = FirebaseAuth.instance.currentUser;
  final idToken = await user?.getIdToken();
  return {
    'Content-Type': 'application/json',
    if (idToken != null) 'Authorization': 'Bearer $idToken',
  };
}
