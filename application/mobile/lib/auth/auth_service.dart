import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:vegito/vegetable/vegetable_buyer/vegetable_buyer_page.dart'
    as Config;

class AuthService {
  final http.Client client;
  final String backendUrl;
  final FirebaseAuth _auth;

  AuthService(
      {FirebaseAuth? firebaseAuth, http.Client? client, String? backendUrl})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        backendUrl = backendUrl ?? Config.backendUrl,
        client = client ?? http.Client();

  /// Connecte anonymement l'utilisateur s'il n'y en a pas déjà un.
  Future<User?> ensureSignedIn() async {
    final user = _auth.currentUser;
    if (user != null) return user;
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  /// Met à niveau un compte anonyme vers un compte email/mot de passe.
  Future<void> upgradeWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return;
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await user.linkWithCredential(credential);
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Connexion via Google
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Connexion via Facebook
  Future<UserCredential?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) return null;

    final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
    return await _auth.signInWithCredential(credential);
  }

  Future<bool> verifyBackendAuth(String? idToken) async {
    if (idToken == null || idToken.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/auth-check'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      // Log error or handle accordingly
      throw Exception('Backend auth check failed: $e');
    }
  }
}
