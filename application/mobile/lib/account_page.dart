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

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final userCredential =
        await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
    final user = userCredential.user;

    if (user != null) {
      final keys = await WalletService.getKeys(user.uid);
      setState(() {
        //     recoveryKey = keys['recoveryKey'];
        //   });

        //   // Affichage d'une boîte de dialogue avec la clé de récupération
        //   _showRecoveryDialog();
        // Map<String, String> keys = await WalletService.getKeys();
        // setState(() {
        var recoveryKey = keys['recoveryKey'];
        if (recoveryKey != null) {
          _privateKey = recoveryKey;
        }
        _balance = "0.00 BTC"; // Simuler le solde
      });
    }
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
          ],
        ),
      ),
    );
  }
}
