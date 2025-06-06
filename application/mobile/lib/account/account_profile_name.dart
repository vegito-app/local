import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../user/user_provider.dart';

class AccountProfileName extends StatelessWidget {
  const AccountProfileName({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = authProvider.user?.displayName ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profil public",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: displayName,
          decoration: const InputDecoration(
            labelText: "Nom public (affiché dans les commandes)",
          ),
          onFieldSubmitted: (value) async {
            final uid = authProvider.user?.uid;
            if (uid != null) {
              await userProvider.updateDisplayName(uid, value.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nom public mis à jour")),
              );
            }
          },
        ),
      ],
    );
  }
}
