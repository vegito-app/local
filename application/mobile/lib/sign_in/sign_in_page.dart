import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Ajouté pour kReleaseMode
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<UserCredential?> _signInWithFirebase(BuildContext context) async {
    try {
      if (!kReleaseMode) {
        await FirebaseAuth.instance.useAuthEmulator(
            'localhost', 9099); // Utilisation de l'émulateur en dev
      }
      final user = FirebaseAuth.instance.currentUser;
      // Connexion anonyme si pas connecté
      if (user == null) {
        return await FirebaseAuth.instance.signInAnonymously();
      }

      // Déjà connecté, inutile de re-signer, retourner null
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion Firebase : $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Se connecter')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _signInWithFirebase(context);
            Navigator.of(context).pop(); // Retour à l'écran précédent
          },
          child: const Text('Connexion Firebase'),
        ),
      ),
    );
  }
}
