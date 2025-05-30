import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../vegetable/vegetable_model.dart';
import 'order_model.dart' as vegetable;
import 'package:provider/provider.dart';
import '../vegetable/vegetable_provider.dart';

class ConsumerOrderScreen extends StatelessWidget {
  const ConsumerOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('clientId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune commande trouvée.'));
          }

          final orders = orderSnapshot.data!.docs
              .map((doc) => vegetable.Order.fromDoc(doc))
              .toList();

          return FutureBuilder<List<Vegetable>>(
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
                  final imageUrl =
                      veg.images.isNotEmpty ? veg.images.first.url : null;

                  return Card(
                    child: ListTile(
                      leading: imageUrl != null
                          ? Image.network(imageUrl,
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
          );
        },
      ),
    );
  }
}
