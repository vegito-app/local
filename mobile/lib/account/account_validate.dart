import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/wallet/wallet_provider.dart';

import '../auth/auth_provider.dart';

class AccountValidate extends StatefulWidget {
  const AccountValidate({super.key});

  @override
  _AccountValidateState createState() => _AccountValidateState();
}

class _AccountValidateState extends State<AccountValidate>
    with SingleTickerProviderStateMixin {
  Future<void> _loadWallet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) throw Exception("Utilisateur non authentifié");
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.refresh(user.uid);
    final wallet = walletProvider.wallet;
    if (wallet!.isCompromised) {
      throw Exception("Accès compromis détecté.");
    }
  }

  Future<String?> _promptForEmail(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrer votre email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptForPassword(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrer un mot de passe'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            try {
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
        const SizedBox(height: 20),
        const Text("Sécuriser mon compte avec :",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await authProvider.signInWithGoogle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Compte sécurisé avec Google ✅"),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Erreur Google : $e"),
                        backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.account_circle),
              label: const Text("Google"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await authProvider.signInWithFacebook();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Compte sécurisé avec Facebook ✅"),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Erreur Facebook : $e"),
                        backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.facebook),
              label: const Text("Facebook"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final email = await _promptForEmail(context);
                final password = await _promptForPassword(context);
                if (email != null &&
                    email.isNotEmpty &&
                    password != null &&
                    password.isNotEmpty) {
                  try {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.upgradeWithEmail(email, password);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Compte lié à $email ✅"),
                          backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Erreur email : $e"),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              icon: const Icon(Icons.email),
              label: const Text("Email"),
            ),
          ],
        ),
      ],
    );
  }
}
