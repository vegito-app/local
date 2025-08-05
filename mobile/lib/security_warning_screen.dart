import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SecurityWarningScreen extends StatefulWidget {
  const SecurityWarningScreen({super.key});

  @override
  State<SecurityWarningScreen> createState() => _SecurityWarningScreenState();
}

class _SecurityWarningScreenState extends State<SecurityWarningScreen> {
  @override
  void initState() {
    super.initState();
    if (!kDebugMode) {
      Future.delayed(const Duration(seconds: 10), () {
        exit(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Votre appareil présente un risque de sécurité.\n\nPar mesure de précaution, l'accès est désactivé pour protéger vos actifs.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Quitter l\'application'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('⚠️ Forcer accès (Mode Debug)'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mode debug - accès forcé',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
