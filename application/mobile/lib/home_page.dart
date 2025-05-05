import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'account_page.dart';
import 'sign_in_page.dart';
import 'wallet_screen.dart';
import 'wallet_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? _recoveryKey;
  bool _isLoading = false;
  bool _showRecoveryKey = false;
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
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final privateKey = await WalletService.getPrivateKey();
      final recoveryKey = await WalletService.getRecoveryKey();

      setState(() {
        _recoveryKey = recoveryKey;
        _showRecoveryKey = false;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallet: $e')),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateRecoveryKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final newRecoveryKey = await WalletService.generateRecoveryKey(user.uid);

      setState(() {
        _recoveryKey = newRecoveryKey;
        _showRecoveryKey = true;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate recovery key: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => WalletScreen()),
                );
              },
              child: const Text('Aller à Mon Wallet'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                );
              },
              child: const Text('Aller à Mon Compte'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
