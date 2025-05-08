import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'account/account_page.dart';
import 'auth_guard.dart';
import 'config.dart';
import 'firebase_config.dart';
import 'home_page/home_page.dart';
import 'wallet/wallet_screen.dart';

Future<void> signInWithFirebase() async {
  try {
    if (!kReleaseMode) {
      await FirebaseAuth.instance.useAuthEmulator('firebase-emulators', 9099);
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Erreur de connexion Firebase : $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseConfigService configService = FirebaseConfigService();
  var backendUrl = Config.backendUrl;
  FirebaseOptions options =
      await configService.getConfig('$backendUrl/ui/config/firebase');

  await Firebase.initializeApp(options: options);

  await signInWithFirebase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      title: 'Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGuard(
        child: HomePage(),
      ),
      routes: {
        '/wallet': (context) => const AuthGuard(child: WalletScreen()),
        '/account': (context) => const AuthGuard(child: AccountPage()),
      },
    );
  }
}
