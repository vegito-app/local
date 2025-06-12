// ignore_for_file: unused_import

import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/order/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../vegetable/vegetable_list_provider.dart';
import '../vegetable/vegetable_model.dart';
import 'order_model.dart' as vegetable;

class ConsumerOrderScreen extends StatelessWidget {
  const ConsumerOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context);

    final user = authProvider.user;
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text('Utilisateur non connecté')));
    }

    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = orderProvider.orders;
    // Continue affichage avec les orders chargées...
    if (orders.isEmpty) {
      return const Center(child: Text('Aucune commande trouvée.'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: FutureBuilder<List<Vegetable>>(
        future: Provider.of<VegetableListProvider>(context, listen: false)
            .findByIds(orders.map((o) => o.vegetableId).toList()),
        builder: (context, vegSnapshot) {
          if (!vegSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final vegetables = vegSnapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final veg =
                  vegetables.firstWhere((v) => v.id == order.vegetableId);
              final imagePath =
                  veg.images.isNotEmpty ? veg.images.first.publicUrl : null;

              return Card(
                child: ListTile(
                  leading: imagePath != null
                      ? Image.network(imagePath,
                          width: 64, height: 64, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 64),
                  title: Text('${veg.name} x${order.quantity}'),
                  subtitle: Text('Statut : ${order.status}'),
                  trailing: Text(
                    '${(veg.priceCents * order.quantity) / 100}€',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
