// ignore_for_file: directives_ordering

import 'package:car2go/wallet/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../account/account_validate.dart';
import 'wallet_private_key_button.dart';
import 'wallet_recovery_key_section.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_security_banner.dart';

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
    _loadWallet();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      // Removed redundant addPostFrameCallback with SnackBar
      return;
    }

    try {
      final wallet = Provider.of<WalletProvider>(context, listen: false).wallet;
      setState(() {
        _recoveryKey = wallet?.recoveryKey;
        _recoveryKeyVersion = wallet?.recoveryKeyVersion;
        _isLoading = false;
        _showRecoveryKey = false;
        _isCompromised = wallet?.isCompromised ?? false;
        _fadeController.reset();
      });
      if (_recoveryKey != null && _recoveryKey!.isNotEmpty && !_isCompromised) {
        _fadeController.forward();
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement du wallet : $e')),
        );
      });
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setContext(context);
    final isAnonymous = authProvider.isAnonymous;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Wallet")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  const AuthSecurityBanner(contextType: AuthContext.wallet),
                  const ShowPrivateKeyButton(),
                  const SizedBox(height: 50),
                  const Text(
                    "Clé de récupération :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isAnonymous) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Disponible uniquement avec un compte vérifié.\nUn compte vérifié permet de récupérer la seconde moitié de la clé depuis notre plateforme.",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.key),
                      onPressed: (isAnonymous || _isCompromised)
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
                    if (isAnonymous) ...[
                      const AccountValidate(),
                      const SizedBox(height: 10),
                    ],
                    WalletRecoveryKeySection(
                      recoveryKey: _recoveryKey,
                      recoveryKeyVersion: _recoveryKeyVersion,
                      showRecoveryKey: _showRecoveryKey,
                      fadeAnimation: _fadeAnimation,
                      scaleAnimation: _scaleAnimation,
                    ),
                  ],
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  const Text(
                    "Avertissement :\nNe partagez jamais votre clé de récupération avec qui que ce soit. Gardez-la en sécurité.",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // const Text(
                  //   "Si vous avez des questions, contactez-nous à support@example.com",
                  //   style: TextStyle(color: Colors.grey),
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              ),
      ),
    );
  }
}
