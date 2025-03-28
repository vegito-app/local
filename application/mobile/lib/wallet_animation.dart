import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const WalletAnimationApp());
}

class WalletAnimationApp extends StatelessWidget {
  const WalletAnimationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Animation',
      theme: ThemeData.dark(),
      home: const WalletAnimationScreen(),
    );
  }
}

class WalletAnimationScreen extends StatefulWidget {
  const WalletAnimationScreen({super.key});

  @override
  _WalletAnimationScreenState createState() => _WalletAnimationScreenState();
}

class _WalletAnimationScreenState extends State<WalletAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String? privateKey;
  String? recoveryKey;
  String? xorKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  String generateKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  void generateWallet() {
    setState(() {
      privateKey = generateKey();
      recoveryKey = generateKey();
      xorKey = base64Encode(
        utf8
            .encode(privateKey!)
            .map((e) => e ^ utf8.encode(recoveryKey!)[0])
            .toList(),
      );
      _controller.forward(from: 0);
    });
  }

  void recoverPrivateKey() {
    setState(() {
      privateKey = base64Encode(
        utf8
            .encode(xorKey!)
            .map((e) => e ^ utf8.encode(recoveryKey!)[0])
            .toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Animation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  if (privateKey != null) ...[
                    const Text('Private Key:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(privateKey!,
                        style: const TextStyle(color: Colors.greenAccent)),
                  ],
                  if (recoveryKey != null) ...[
                    const SizedBox(height: 10),
                    const Text('Recovery Key:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(recoveryKey!,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 255, 64, 204))),
                  ],
                  if (xorKey != null) ...[
                    const SizedBox(height: 10),
                    const Text('XorKey (Stocké sur Firestore):',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(xorKey!,
                        style: const TextStyle(color: Colors.blueAccent)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateWallet,
              child: const Text('Créer Wallet'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: recoverPrivateKey,
              child: const Text('Récupérer Private Key'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
