import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../client/client_location_model.dart';
import '../order/order_card.dart';
import '../order/order_model.dart';
import '../order/order_summit.dart';
import '../vegetable_upload/vegetable_model.dart';
import 'delivery_map_screen.dart';

class DeliveryPlannerScreen extends StatelessWidget {
  const DeliveryPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournée du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () async {
              final vegSnapshot = await firestore.FirebaseFirestore.instance
                  .collection('vegetables')
                  .where('ownerId', isEqualTo: user.uid)
                  .get();

              final vegIds = vegSnapshot.docs.map((d) => d.id).toList();

              final orderSnapshot = await firestore.FirebaseFirestore.instance
                  .collection('orders')
                  .where('vegetableId', whereIn: vegIds)
                  .get();

              final clientIds = orderSnapshot.docs
                  .map((doc) => Order.fromDoc(doc).clientId)
                  .toSet()
                  .toList();

              final clients = <ClientLocation>[];

              for (final clientId in clientIds) {
                final userDoc = await firestore.FirebaseFirestore.instance
                    .collection('users')
                    .doc(clientId)
                    .get();
                if (userDoc.exists) {
                  final data = userDoc.data()!;
                  if (data.containsKey('location')) {
                    clients.add(ClientLocation.fromMap(clientId, data));
                  }
                }
              }

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryMapScreen(clients: clients),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter résumé PDF',
            onPressed: () async {
              final vegSnapshot = await firestore.FirebaseFirestore.instance
                  .collection('vegetables')
                  .where('ownerId', isEqualTo: user.uid)
                  .get();

              final vegMap = {
                for (var doc in vegSnapshot.docs) doc.id: Vegetable.fromDoc(doc)
              };

              final orderSnapshot = await firestore.FirebaseFirestore.instance
                  .collection('orders')
                  .where('vegetableId', whereIn: vegMap.keys.toList())
                  .orderBy('createdAt')
                  .get();

              final orders =
                  orderSnapshot.docs.map((doc) => Order.fromDoc(doc)).toList();

              final pdfBytes = await generateSummaryPdf(orders, vegMap);

              await Printing.layoutPdf(onLayout: (_) => pdfBytes);
            },
          ),
        ],
      ),
      body: FutureBuilder<firestore.QuerySnapshot>(
        future: firestore.FirebaseFirestore.instance
            .collection('vegetables')
            .where('ownerId', isEqualTo: user.uid)
            .get(),
        builder: (context, vegSnapshot) {
          if (!vegSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final vegMap = {
            for (var doc in vegSnapshot.data!.docs)
              doc.id: Vegetable.fromDoc(doc)
          };

          return StreamBuilder<firestore.QuerySnapshot>(
            stream: firestore.FirebaseFirestore.instance
                .collection('orders')
                .where('vegetableId', whereIn: vegMap.keys.toList())
                .orderBy('createdAt')
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (!orderSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = orderSnapshot.data!.docs.map((doc) {
                return Order.fromDoc(doc);
              }).toList();

              if (orders.isEmpty) {
                return const Center(
                    child: Text('Aucune commande pour aujourd’hui.'));
              }

              final statusGroups = {
                'pending': <Order>[],
                'prepared': <Order>[],
                'loaded': <Order>[],
                'delivered': <Order>[],
              };

              for (final order in orders) {
                statusGroups[order.status]?.add(order);
              }

              final summaryWidget = Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Tournée du jour : ${orders.length} commandes • '
                  '${statusGroups['pending']!.length} à préparer • '
                  '${statusGroups['prepared']!.length} récoltées • '
                  '${statusGroups['loaded']!.length} chargées • '
                  '${statusGroups['delivered']!.length} livrées',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              );

              final ordersByClient = <String, List<Order>>{};
              for (final order in orders) {
                ordersByClient.putIfAbsent(order.clientId, () => []).add(order);
              }

              final clientSections = ordersByClient.entries.map((entry) {
                final clientId = entry.key;
                final clientOrders = entry.value;

                return FutureBuilder<firestore.DocumentSnapshot>(
                  future: firestore.FirebaseFirestore.instance
                      .collection('users')
                      .doc(clientId)
                      .get(),
                  builder: (context, snapshot) {
                    final clientData = snapshot.hasData && snapshot.data!.exists
                        ? snapshot.data!.data() as Map<String, dynamic>
                        : {};
                    final clientName = clientData['displayName'] ?? clientId;
                    final address = clientData['address'];
                    final location = clientData['location'];
                    final phone = clientData['phone'];
                    final email = clientData['email'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('👤 $clientName',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              if (address != null)
                                Text('📍 Adresse : $address'),
                              if (location != null)
                                Text('🧭 Localisation : $location'),
                              if (phone != null) Text('📞 Téléphone : $phone'),
                              if (email != null) Text('📧 Email : $email'),
                            ],
                          ),
                        ),
                        ...clientOrders.map((order) {
                          final veg = vegMap[order.vegetableId];
                          if (veg == null) return const SizedBox.shrink();
                          return OrderCard(
                            vegetable: veg,
                            order: order,
                            onStatusChanged: (value) {
                              firestore.FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(order.id)
                                  .update({'status': value});
                            },
                          );
                        }),
                      ],
                    );
                  },
                );
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  summaryWidget,
                  ...clientSections,
                ],
              );
            },
          );
        },
      ),
    );
  }
}
