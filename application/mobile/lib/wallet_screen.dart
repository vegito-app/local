// ignore_for_file: directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wallet_service.dart';

class WalletRecoveryKeySection extends StatelessWidget {
  final String? recoveryKey;
  final String? recoveryKeyVersion;
  final bool showRecoveryKey;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const WalletRecoveryKeySection({
    Key? key,
    required this.recoveryKey,
    required this.recoveryKeyVersion,
    required this.showRecoveryKey,
    required this.fadeAnimation,
    required this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recoveryKey == null || recoveryKey!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Aucune clé de récupération trouvée. Vous pouvez en générer une nouvelle.",
          style: TextStyle(fontSize: 16, color: Colors.orange),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              showRecoveryKey ? (recoveryKey ?? "") : "",
              style: const TextStyle(fontSize: 16, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            if (showRecoveryKey) ...[
              const SizedBox(height: 8),
              Text(
                "Version: ${recoveryKeyVersion ?? "?"}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: recoveryKey ?? ""));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'RecoveryKey copiée dans le presse-papier. Veuillez la protéger.',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text("Copier la RecoveryKey"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WalletScreen extends StatefulWidget {
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
      String? privateKey = await WalletService.getPrivateKey();
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
      String? recoveryKey = await WalletService.getRecoveryKey();
      String? recoveryKeyVersion =
          await WalletService.getRecoveryKeyVersion(user.uid, 0);
      setState(() {
        _recoveryKey = recoveryKey;
        _recoveryKeyVersion = recoveryKeyVersion ?? "Version inconnue";
        _isLoading = false;
        _showRecoveryKey = false;
        _isCompromised = false;
        _fadeController.reset();
      });
      if (recoveryKey != null && recoveryKey.isNotEmpty) {
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

  Future<void> _generateRecoveryKey() async {
    setState(() {
      _isLoading = true;
      _showRecoveryKey = false;
      _fadeController.reset();
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non authentifié");
      }
      await WalletService.generateRecoveryKey(user.uid);
      await _loadWallet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'RecoveryKey générée avec succès. Veuillez la sauvegarder en lieu sûr.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _recoveryKey = "Erreur génération : ${e.toString()}";
        _isLoading = false;
        _showRecoveryKey = false;
        _fadeController.reset();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la génération de la RecoveryKey. Veuillez réessayer. Détail : ${e.toString()}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _storeRecoveryKey() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non authentifié");
      }
      await WalletService.generateRecoveryKey(user.uid);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'RecoveryKey stockée avec succès. Votre clé est maintenant sécurisée.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du stockage de la RecoveryKey. Veuillez réessayer. Détail : ${e.toString()}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
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
                  const Text(
                    "Clé de récupération :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_recoveryKey == null || _recoveryKey!.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Aucune clé de récupération trouvée. Vous pouvez en générer une nouvelle.",
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isCompromised ? null : _generateRecoveryKey,
                      child: const Text("Générer une RecoveryKey"),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _isCompromised
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
                      child: Text(_showRecoveryKey
                          ? "Masquer la RecoveryKey"
                          : "Afficher la RecoveryKey"),
                    ),
                    const SizedBox(height: 10),
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
                  ElevatedButton(
                    onPressed: _isCompromised ? null : _loadWallet,
                    child: const Text("Rafraîchir la RecoveryKey et Version"),
                  ),
                  if (_recoveryKey != null && _recoveryKey!.isNotEmpty) ...[
                    ElevatedButton(
                      onPressed: _isCompromised ? null : _generateRecoveryKey,
                      child: const Text("Générer une RecoveryKey"),
                    ),
                    ElevatedButton(
                      onPressed: _isCompromised ? null : _storeRecoveryKey,
                      child: const Text("Stocker la RecoveryKey"),
                    ),
                  ],
                  if (FirebaseAuth.instance.currentUser?.isAnonymous ==
                      true) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final userCredential = await FirebaseAuth.instance
                              .signInWithProvider(GoogleAuthProvider());
                          await _loadWallet();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Compte validé avec succès. Vos fonds sont maintenant sécurisés.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erreur lors de la validation du compte. Veuillez réessayer. Détail : ${e.toString()}',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                      child: const Text("Valider mon compte"),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
