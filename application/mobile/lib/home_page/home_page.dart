import 'package:car2go/wallet/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../home_page/home_page_actions.dart';
// ignore: unused_import
import '../wallet/wallet_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Important : ne pas appeler _loadWallet() ici
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWallet(); // Maintenant c'est safe ici
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non authentifié')),
        );
      });
      return;
    }

    try {
      final _ = Provider.of<WalletProvider>(context, listen: false).wallet;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement du wallet : $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: const Center(child: ActionButtons()),
    );
  }
}
