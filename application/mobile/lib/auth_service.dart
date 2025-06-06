import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

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
}
