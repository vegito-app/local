import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return; // L'utilisateur a annulé

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  if (!kReleaseMode) {
    await FirebaseAuth.instance.useAuthEmulator('firebase-emulators', 9099);
  }
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.isAnonymous) {
    await user.linkWithCredential(credential); // Upgrade compte anonyme
  } else {
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
