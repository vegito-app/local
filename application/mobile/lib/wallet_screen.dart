import 'package:flutter/material.dart';
import 'wallet_service.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? _recoveryKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      String? recoveryKey = await WalletService.getRecoveryKey();
      setState(() {
        _recoveryKey = recoveryKey ?? "Aucune clé de récupération trouvée";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _recoveryKey = "Erreur : ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Wallet")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Clé de récupération :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    _recoveryKey ?? "",
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadWallet,
                    child: const Text("Rafraîchir"),
                  ),
                ],
              ),
      ),
    );
  }
}
