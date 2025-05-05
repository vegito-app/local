import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'account_page.dart';
import 'auth_guard.dart';
import 'config.dart';
import 'firebase_config.dart';
import 'home_page.dart';
import 'wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseConfigService configService = FirebaseConfigService();
  var backendUrl = Config.backendUrl;
  FirebaseOptions options =
      await configService.getConfig('$backendUrl/ui/config/firebase');

  await Firebase.initializeApp(options: options);

// Ideal time to initialize
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
//...
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGuard(
        child: HomePage(),
      ),
      routes: {
        '/wallet': (context) => AuthGuard(child: WalletScreen()),
        '/account': (context) => const AuthGuard(child: AccountPage()),
      },
    );
  }
}
