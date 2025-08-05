import 'package:flutter/material.dart';

import 'order/consumer_order_screen.dart';
import 'order/order_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon activité")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "👤 En tant que client",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text("Mes commandes"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ConsumerOrderScreen(),
                ));
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "🧑‍🌾 En tant que planteur",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag),
              label: const Text("Commandes reçues"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const OrderScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
