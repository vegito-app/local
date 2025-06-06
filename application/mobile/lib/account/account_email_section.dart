import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class AccountEmailSection extends StatelessWidget {
  const AccountEmailSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Adresse e-mail :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(authProvider.user?.email ?? "Non disponible",
                  style: const TextStyle(fontSize: 20, color: Colors.blue)),
            ],
          );
        }
        return const Text("Aucune adresse e-mail disponible.",
            style: TextStyle(fontSize: 20, color: Colors.red));
      },
    );
  }
}
