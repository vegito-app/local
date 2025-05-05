import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'wallet_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _privateKey = "??????????????";
  bool _isKeyVisible = false;
  String _balance = "Chargement...";
  bool _hasRecoveryKey = false;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      if (userCredential.user != null) {
        await _initializeWallet();
      }
    } else {
      await _initializeWallet();
    }
  }

  Future<void> _initializeWallet() async {
    final privateKey = await WalletService.getPrivateKey();
    final recoveryKeyVersion = await WalletService.getRecoveryKey();
    setState(() {
      _privateKey = privateKey;
      _balance = "0.00 BTC"; // Simuler le solde
      _hasRecoveryKey = recoveryKeyVersion != null;
    });
  }

  void _toggleKeyVisibility() {
    setState(() {
      _isKeyVisible = !_isKeyVisible;
    });
  }

  void _copyToClipboard() {
    FlutterClipboard.copy(_privateKey).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clé copiée ! Soyez prudent.")),
      );
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
            const Text("Clé Privée :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onLongPress: _toggleKeyVisibility,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[200],
                ),
                child: Text(
                  _isKeyVisible ? _privateKey : "??????????????",
                  style: const TextStyle(fontSize: 16, fontFamily: "monospace"),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: const Text("Copier la clé privée"),
            ),
            if (FirebaseAuth.instance.currentUser?.isAnonymous == true) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final userCredential = await FirebaseAuth.instance
                        .signInWithProvider(GoogleAuthProvider());
                    await _initializeWallet();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Compte validé avec succès !')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Erreur lors de la validation : ${e.toString()}')),
                    );
                  }
                },
                child: const Text("Valider mon compte"),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await WalletService.generateRecoveryKey(
                    FirebaseAuth.instance.currentUser?.uid ?? "");
                await _initializeWallet();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Clé de récupération générée !')),
                );
              },
              child: const Text("Créer ma clé de récupération"),
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
        ),
      ),
    );
  }
}
