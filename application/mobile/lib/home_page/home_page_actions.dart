import 'package:flutter/material.dart';

import '../account/account_page.dart';
import '../wallet/wallet_screen.dart';
import '../vegetable_buyer/vegetable_buyer_page.dart';
import '../vegetable_upload/vegetable_upload_screen.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Que souhaitez-vous faire aujourd’hui ?",
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        const _GoToVegetableBuyerButton(),
        const SizedBox(height: 16),
        const _GoToVegetableUploadButton(),
        const SizedBox(height: 16),
        const _GoToWalletButton(),
        const SizedBox(height: 16),
        const _GoToAccountButton(),
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

class _GoToVegetableBuyerButton extends StatelessWidget {
  const _GoToVegetableBuyerButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      icon: const Icon(Icons.shopping_basket),
      label: const Text("🥬 Commander des légumes"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const VegetableBuyerPage()),
        );
      },
    );
  }
}

class _GoToVegetableUploadButton extends StatelessWidget {
  const _GoToVegetableUploadButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      icon: const Icon(Icons.store_mall_directory),
      label: const Text("🧺 Vendre mes légumes"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => const VegetableUploadScreen()),
        );
      },
    );
  }
}
