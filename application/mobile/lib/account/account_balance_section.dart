import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class AccountBalanceSection extends StatelessWidget {
  const AccountBalanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final balance = auth.balance;
        final isLoading = auth.loadingBalance;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Solde :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            isLoading
                ? const CircularProgressIndicator()
                : Text(
                    balance,
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                  ),
            TextButton.icon(
              onPressed: () => auth.loadBalance(),
              icon: const Icon(Icons.refresh),
              label: const Text("Rafraîchir"),
            ),
          ],
        );
      },
    );
  }
}
