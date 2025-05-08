import 'package:flutter/material.dart';

import '../account/account_page.dart';
import '../wallet/wallet_screen.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GoToWalletButton(),
        SizedBox(height: 16),
        _GoToAccountButton(),
      ],
    );
  }
}

class _GoToWalletButton extends StatelessWidget {
  const _GoToWalletButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const WalletScreen()),
        );
      },
      child: const Text('Aller à Mon Wallet'),
    );
  }
}

class _GoToAccountButton extends StatelessWidget {
  const _GoToAccountButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
      },
      child: const Text('Aller à Mon Compte'),
    );
  }
}
