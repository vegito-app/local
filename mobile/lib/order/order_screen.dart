import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../vegetable/vegetable_list_provider.dart';
import '../vegetable/vegetable_model.dart';
import 'order_model.dart' as order_model;
import 'order_provider.dart';

class OrderWithVegetable {
  final order_model.Order order;
  final Vegetable vegetable;

  OrderWithVegetable({required this.order, required this.vegetable});
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non authentifié')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Commandes reçues')),
      body: FutureBuilder<List<OrderWithVegetable>>(
        future: _loadOrders(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final combined = snapshot.data!;

          if (combined.isEmpty) {
            return const Center(child: Text('Aucune commande.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: combined.length,
            itemBuilder: (context, index) {
              final entry = combined[index];
              final order = entry.order;
              final vegetable = entry.vegetable;
              final imagePath = vegetable.images.isNotEmpty
                  ? vegetable.images.first.publicUrl
                  : null;

              return Card(
                child: ListTile(
                  leading: imagePath != null
                      ? Image.network(imagePath,
                          width: 64, height: 64, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 64),
                  title: Text('${vegetable.name} x${order.quantity}'),
                  subtitle: Text('Statut : ${order.status}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      final orderProvider =
                          Provider.of<OrderProvider>(context, listen: false);
                      orderProvider.updateOrderStatus(order.id, value);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'prepared', child: Text('Préparé')),
                      PopupMenuItem(value: 'delivered', child: Text('Livré')),
                    ],
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

Future<List<OrderWithVegetable>> _loadOrders(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final provider = Provider.of<VegetableListProvider>(context, listen: false);
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);

  final user = authProvider.user;
  if (user == null) return [];

  final vegetables = provider.vegetablesByOwner(user.uid);
  final vegetableIds = vegetables.map((v) => v.id).toList();

  final orders = await orderProvider.loadOrdersByVegetableIds(vegetableIds);

  return orders.map((o) {
    final veg = vegetables.firstWhere((v) => v.id == o.vegetableId);
    return OrderWithVegetable(order: o, vegetable: veg);
  }).toList();
}
