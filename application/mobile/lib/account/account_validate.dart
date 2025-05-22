import 'package:car2go/wallet/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
