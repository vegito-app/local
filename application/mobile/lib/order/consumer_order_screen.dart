import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../vegetable_upload/vegetable_model.dart';
import 'order_model.dart' as vegetable;

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
            future: Future.wait(orders.map((order) async {
              final vegDoc = await FirebaseFirestore.instance
                  .collection('vegetables')
                  .doc(order.vegetableId)
                  .get();
              return Vegetable.fromDoc(vegDoc);
            })),
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
                  final veg = vegetables[index];

                  return Card(
                    child: ListTile(
                      leading:
                          Image.network(veg.imageUrl, width: 64, height: 64),
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
