import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class AccountAuthStatusSection extends StatelessWidget {
  const AccountAuthStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Statut de connexion :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            authProvider.isAuthenticated ? "Connecté" : "Non connecté",
            style: TextStyle(
              fontSize: 20,
              color: authProvider.isAuthenticated ? Colors.green : Colors.red,
            ),
          ),
        ],
      );
    });
  }
}
