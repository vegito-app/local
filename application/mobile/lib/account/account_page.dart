import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../wallet/wallet_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _balance = "Chargement...";

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _initializeWallet();
    }
  }

  Future<void> _initializeWallet() async {
    setState(() {
      _balance = "0.00 BTC"; // Simuler le solde
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Compte temporaire : enregistrez votre clé sinon vos fonds pourraient être perdus !",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Solde :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(_balance,
                style: const TextStyle(fontSize: 20, color: Colors.blue)),
            const SizedBox(height: 20),
            if (FirebaseAuth.instance.currentUser?.isAnonymous == true) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await signInWithFirebaseGoogle(context);
                },
                child: const Text("Valider mon compte"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _initializeWallet();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Données rafraîchies.')),
                  );
                },
                child: const Text("Rafraîchir"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> signInWithFirebaseGoogle(BuildContext context) async {
  try {
    if (!kReleaseMode) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      await user.linkWithCredential(credential);
    } else {
      await FirebaseAuth.instance.signInWithCredential(credential);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Connexion réussie avec Google.")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur de connexion Google : $e")),
    );
  }
}
