import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'firebase_config.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseConfigService configService = FirebaseConfigService();
  var backendUrl = Config.backendUrl;
  FirebaseOptions options =
      await configService.getConfig('$backendUrl/ui/config/firebase');

  await Firebase.initializeApp(options: options);

// Ideal time to initialize
  await FirebaseAuth.instance.useAuthEmulator('dev', 9099);
//...
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
