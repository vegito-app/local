import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  late final Stream<User?> _authStream;
  late final StreamSubscription<User?> _authSubscription;

  BuildContext? _context;
  AuthProvider() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authSubscription = _authStream.listen((user) async {
      _user = user;

      // Création automatique d'un utilisateur anonyme si aucun
      if (_user == null) {
        try {
          final userCredential =
              await FirebaseAuth.instance.signInAnonymously();
          _user = userCredential.user;
        } catch (e) {
          _showSnackBar(
            "Erreur de connexion anonyme : $e",
            backgroundColor: Colors.orange,
          );
        }
      }

      if (_user != null && _user!.isAnonymous) {
        _showSnackBar(
          "Connecté anonymement. Pensez à sécuriser votre compte plus tard.",
          backgroundColor: Colors.red,
        );
      }

      notifyListeners();
    });
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (_context == null) return;
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? true;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
