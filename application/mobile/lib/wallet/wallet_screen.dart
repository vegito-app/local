// ignore_for_file: directives_ordering

import 'package:car2go/wallet/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wallet_service.dart';
import 'wallet_backend.dart';
import '../account/account_validate.dart';
import 'wallet_private_key_button.dart';
import 'wallet_recovery_key_section.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  String? _recoveryKey;
  String? _recoveryKeyVersion;
  bool _isLoading = true;
  bool _showRecoveryKey = false;
  bool _isCompromised = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late final Stream<User?> _authStateChanges;

  bool _isAnonymous() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.isAnonymous;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(_fadeController);
    _authStateChanges = FirebaseAuth.instance.authStateChanges();
    _authStateChanges.listen((user) {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Session expirée. Vous êtes maintenant en mode invité. Veuillez vous reconnecter pour sécuriser vos fonds.",
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        setState(() {
          _isCompromised = false;
          _isLoading = true;
          _recoveryKey = null;
          _recoveryKeyVersion = null;
          _showRecoveryKey = false;
          _fadeController.reset();
        });
        _loadWallet();
      }
    });
    _loadWallet();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non authentifié");
      }
      String? privateKey = await getPrivateKeyWIF();
      if (privateKey.contains("compromis")) {
        setState(() {
          _recoveryKey = "Appareil compromis, accès refusé.";
          _recoveryKeyVersion = "Impossible";
          _isLoading = false;
          _showRecoveryKey = false;
          _isCompromised = true;
          _fadeController.reset();
        });
        return;
      }
      String? recoveryKey = await WalletStorage.getLocallyStoredRecoveryKey();
      String? recoveryKeyVersion = await getRecoveryKeyVersion(user.uid);
      setState(() {
        _recoveryKey = recoveryKey;
        _recoveryKeyVersion = recoveryKeyVersion ?? "Version inconnue";
        _isLoading = false;
        _showRecoveryKey = false;
        _isCompromised = false;
        _fadeController.reset();
      });
      if (recoveryKey!.isNotEmpty) {
        _fadeController.forward();
      }
    } catch (e) {
      setState(() {
        _recoveryKey = "Erreur : ${e.toString()}";
        _recoveryKeyVersion = "Erreur version";
        _isLoading = false;
        _showRecoveryKey = false;
        _isCompromised = false;
        _fadeController.reset();
      });
    }
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
      appBar: AppBar(title: const Text("Mon Wallet")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ShowPrivateKeyButton(),
                  // ... autres widgets de wallet
                  const SizedBox(height: 50),
                  const Text(
                    "Clé de récupération :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_isAnonymous()) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Disponible uniquement avec un compte vérifié.\nUn compte vérifié permet de récupérer la seconde moitié de la clé depuis notre plateforme.",
                        // style: TextStyle(color: Colors.orange),
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // ] else ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.key),
                    onPressed: (_isAnonymous() || _isCompromised)
                        ? null
                        : () {
                            setState(() {
                              _showRecoveryKey = !_showRecoveryKey;
                              if (_showRecoveryKey) {
                                _fadeController.forward();
                              } else {
                                _fadeController.reverse();
                              }
                            });
                          },
                    label: const Text("Clé de récupération"),
                  ),
                  const AccountValidate(),
                  const SizedBox(height: 10),
                  WalletRecoveryKeySection(
                    recoveryKey: _recoveryKey,
                    recoveryKeyVersion: _recoveryKeyVersion,
                    showRecoveryKey: _showRecoveryKey,
                    fadeAnimation: _fadeAnimation,
                    scaleAnimation: _scaleAnimation,
                  ),
                  // ],
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  // if (_recoveryKey != null && _recoveryKey!.isNotEmpty) ...[
                  //   ElevatedButton(
                  //     onPressed: (_isAnonymous() || _isCompromised)
                  //         ? null
                  //         : _generateRecoveryKey,
                  //     child: const Text("Générer une Clé de récupération 🔑"),
                  //   ),
                  // ],
                ],
              ),
      ),
    );
  }
}
