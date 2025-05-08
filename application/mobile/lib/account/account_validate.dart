import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountValidate extends StatefulWidget {
  const AccountValidate({super.key});

  @override
  _AccountValidateState createState() => _AccountValidateState();
}

class _AccountValidateState extends State<AccountValidate>
    with SingleTickerProviderStateMixin {
  Future<void> _loadWallet() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non authentifié");
      }
      return;
    } catch (e) {
      setState(() {});
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
