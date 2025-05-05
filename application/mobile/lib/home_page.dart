import 'package:flutter/material.dart';
import 'account_page.dart';
import 'sign_in_page.dart';
import 'wallet_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // FutureBuilder(
            //   future: WalletService.getPrivateKey(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return const Text("Erreur lors du chargement du wallet");
            //     } else {
            //       return Text("Wallet: ${snapshot.data!.substring(0, 8)}...",
            //           style: const TextStyle(fontWeight: FontWeight.bold));
            //     }
            //   },
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<AccountPage>(
                      builder: (BuildContext context) {
                    return WalletScreen();
                  }),
                );
              },
              child: const Text("Aller à Mon Wallet"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<AccountPage>(
                      builder: (BuildContext context) {
                    return const AccountPage();
                  }),
                );
              },
              child: const Text("Aller à Mon Compte"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
