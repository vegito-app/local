import 'package:flutter/material.dart';
import 'account_page.dart';
import 'sign_in_page.dart';

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
