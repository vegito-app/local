import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'security_warning_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  Future<User?> _ensureUserIsAuthenticated(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Connecté anonymement. Pensez à sécuriser votre compte plus tard.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur de connexion anonyme : ${e.toString()}')),
        );
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _ensureUserIsAuthenticated(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const SecurityWarningScreen();
        } else {
          return child;
        }
      },
    );
  }
}
