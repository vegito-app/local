import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../vegetable_upload/vegetable_model.dart';
import 'order_model.dart' as order_model;

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
      body: FutureBuilder<firestore.QuerySnapshot>(
        future: firestore.FirebaseFirestore.instance
            .collection('vegetables')
            .where('ownerId', isEqualTo: user.uid)
            .get(),
        builder: (context, vegSnapshot) {
          if (vegSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vegetableIds =
              vegSnapshot.data!.docs.map((doc) => doc.id).toList();

          return StreamBuilder<firestore.QuerySnapshot>(
            stream: firestore.FirebaseFirestore.instance
                .collection('orders')
                .where('vegetableId',
                    whereIn: vegetableIds.isEmpty ? ['_'] : vegetableIds)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Aucune commande.'));
              }

              final orders = orderSnapshot.data!.docs
                  .map((doc) => order_model.Order.fromDoc(doc))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final veg = vegSnapshot.data!.docs
                      .firstWhere((doc) => doc.id == order.vegetableId);
                  final vegetable = Vegetable.fromDoc(veg);

                  return Card(
                    child: ListTile(
                      title: Text('${vegetable.name} x${order.quantity}'),
                      subtitle: Text('Statut : ${order.status}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          firestore.FirebaseFirestore.instance
                              .collection('orders')
                              .doc(order.id)
                              .update({'status': value});
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'prepared', child: Text('Préparé')),
                          PopupMenuItem(
                              value: 'delivered', child: Text('Livré')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
