import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  late final Stream<User?> _authStream;
  late final StreamSubscription<User?> _authSubscription;

  BuildContext? _context;
  final AuthService _authService;

  String _balance = "0.00 €";
  bool _loadingBalance = false;

  AuthProvider({AuthService? service})
      : _authService = service ?? AuthService() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authSubscription = _authStream.listen((user) async {
      _user = user;
      // Délègue la logique d'auth anonyme à AuthService
      if (_user == null) {
        try {
          _user = await _authService.ensureSignedIn();
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

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _showSnackBar("Échec de la connexion Google : $e",
          backgroundColor: Colors.red);
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await _authService.signInWithFacebook();
    } catch (e) {
      _showSnackBar("Échec de la connexion Facebook : $e",
          backgroundColor: Colors.red);
    }
  }

  Future<void> upgradeWithEmail(String email, String password) async {
    try {
      await _authService.upgradeWithEmail(email, password);
    } catch (e) {
      _showSnackBar("Échec de la mise à niveau avec email : $e",
          backgroundColor: Colors.red);
    }
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? true;

  String get balance => _balance;
  bool get loadingBalance => _loadingBalance;

  Future<void> loadBalance() async {
    _loadingBalance = true;
    notifyListeners();

    try {
      // TODO: Remplacer par l'appel réel à un service backend
      await Future.delayed(const Duration(seconds: 1));
      // Simule la récupération du solde, ici fixe pour l'exemple
      _balance = "250.00 €";
    } catch (e) {
      _showSnackBar("Erreur lors du chargement du solde : $e",
          backgroundColor: Colors.red);
    } finally {
      _loadingBalance = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
