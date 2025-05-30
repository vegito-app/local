import 'package:flutter/material.dart';

import '../order/order_card.dart';
import '../order/order_model.dart' as order;
import '../order/order_service.dart';
import '../vegetable/vegetable_model.dart';
import '../vegetable/vegetable_service.dart';
import 'client_location_model.dart';

class ClientDetailScreen extends StatelessWidget {
  final ClientLocation client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    if (client.address == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Adresse manquante"),
            content: const Text(
              "Ce client n'a pas renseigné d'adresse postale. "
              "La livraison s'appuiera uniquement sur sa position géographique.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Compris"),
              ),
            ],
          ),
        );
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(client.displayName)),
      body: FutureBuilder<List<order.Order>>(
        future: OrderService.listByClientId(client.id),
        builder: (context, orderSnapshot) {
          if (!orderSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = orderSnapshot.data!;

          return FutureBuilder<List<Vegetable>>(
            future: VegetableService.listVegetables(),
            builder: (context, vegSnapshot) {
              if (!vegSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final vegMap = {
                for (final veg in vegSnapshot.data!) veg.id: veg,
              };

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text(
                      client.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (client.address != null)
                      Text('📍 Adresse : ${client.address}'),
                    const SizedBox(height: 16),
                    Text(
                      'Commandes du jour',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...orders.map((order) {
                      final veg = vegMap[order.vegetableId];
                      if (veg == null) return const SizedBox.shrink();
                      return OrderCard(
                        vegetable: veg,
                        order: order,
                        onStatusChanged: (value) {
                          OrderService.updateStatus(order.id, value);
                        },
                      );
                    }),
                    const SizedBox(height: 32),
                    Text(
                      '🔒 Les données affichées sont limitées à ce qui est nécessaire à la livraison. '
                      'Merci de respecter la vie privée de vos clients.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
