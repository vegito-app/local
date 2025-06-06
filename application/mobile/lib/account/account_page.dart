import 'package:car2go/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_security_banner.dart';
import 'account_auth_status_section.dart';
import 'account_balance_section.dart';
import 'account_email_section.dart';
import 'account_security_section.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _balance = "Chargement...";

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      await _initializeWallet();
    }
  }

  Future<void> _initializeWallet() async {
    setState(() {
      _balance = "0.00 BTC"; // Simuler le solde
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            AuthSecurityBanner(contextType: AuthContext.account),
            SizedBox(height: 20),
            AccountBalanceSection(),
            SizedBox(height: 20),
            AccountAuthStatusSection(),
            SizedBox(height: 20),
            AccountEmailSection(),
            SizedBox(height: 20),
            AccountSecuritySection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
