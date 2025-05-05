import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'wallet_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? recoveryKey;

  Future<void> _signInWithGoogle() async {
    final userCredential =
        await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
    final user = userCredential.user;

    if (user != null) {
      final rKey = await WalletService.getRecoveryKey();
      setState(() {
        recoveryKey = rKey;
      });

      // Afficher la boîte de dialogue avec la recovery key
      _showRecoveryDialog();
    }
  }

  void _showRecoveryDialog() {
    showDialog(
      barrierDismissible: false, // Empêche la fermeture sans sauvegarder la clé
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clé de récupération"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cette clé est ESSENTIELLE pour restaurer votre wallet. "
              "Si vous la perdez, votre wallet sera irrécupérable ! "
              "Veuillez la noter et la stocker en sécurité.",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                recoveryKey ?? "Erreur",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("J'ai noté ma clé"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Image.asset("assets/images/logo-google.png", height: 20),
                onPressed: _signInWithGoogle,
                label: const Text("Se connecter avec Google"),
              ),
            ],
          ),
        )
      ],
    ));
  }
}
