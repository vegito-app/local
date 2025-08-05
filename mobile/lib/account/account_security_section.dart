import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import 'account_activity_button.dart';
import 'account_profile_name.dart';
import 'account_reputation_toggle_section.dart';
import 'account_validate.dart';

class AccountSecuritySection extends StatelessWidget {
  const AccountSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Statut de sécurité :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            authProvider.isAuthenticated ? "Sécurisé" : "Non sécurisé",
            style: TextStyle(
              fontSize: 20,
              color: authProvider.isAuthenticated ? Colors.green : Colors.red,
            ),
          ),
          if (authProvider.isAuthenticated) ...[
            const Text("Statut de sécurité :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              authProvider.isAnonymous ? "Anonyme" : "Sécurisé",
              style: TextStyle(
                fontSize: 20,
                color: authProvider.isAnonymous ? Colors.red : Colors.green,
              ),
            ),
          ],
          if (authProvider.isAnonymous == true) ...[
            const SizedBox(height: 10),
            const AccountValidate(),
          ],
          const SizedBox(height: 20),
          const AccountProfileName(),
          const SizedBox(height: 12),
          const AccountReputationToggleSection(),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              // ici, on récupère à nouveau le provider pour accéder à la méthode
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.loadBalance();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données rafraîchies.')),
              );
            },
            child: const Text("Rafraîchir"),
          ),
          const SizedBox(height: 20),
          const AccountActivityButton(),
        ],
      );
    });
  }
}
