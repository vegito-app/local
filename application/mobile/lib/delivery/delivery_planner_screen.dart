import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../client/client_location_model.dart';
import '../order/order_card.dart';
import '../order/order_model.dart';
import '../order/order_service.dart';
import '../order/order_summit.dart';
import '../user/user_model.dart';
import '../user/user_service.dart';
import '../vegetable/vegetable_model.dart';
import '../vegetable/vegetable_service.dart';
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
              final vegList = await VegetableService.listVegetables();
              final userVeg =
                  vegList.where((v) => v.ownerId == user.uid).toList();
              final vegIds = userVeg.map((v) => v.id).toList();

              final orders = await OrderService.listByVegetableIds(vegIds);
              final clientIds = orders.map((o) => o.clientId).toSet();

              final clients = <ClientLocation>[];
              for (final clientId in clientIds) {
                final profile = await UserService.getUserProfile(clientId);
                if (profile.location != null) {
                  clients
                      .add(ClientLocation.fromMap(clientId, profile.toMap()));
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
              final vegList = await VegetableService.listVegetables();
              final userVeg =
                  vegList.where((v) => v.ownerId == user.uid).toList();
              final vegMap = {for (var v in userVeg) v.id: v};

              final orders =
                  await OrderService.listByVegetableIds(vegMap.keys.toList());

              final pdfBytes = await generateSummaryPdf(orders, vegMap);

              await Printing.layoutPdf(onLayout: (_) => pdfBytes);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Vegetable>>(
        future: VegetableService.listVegetables(),
        builder: (context, vegSnapshot) {
          if (!vegSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final vegList = vegSnapshot.data!;
          final userVeg = vegList.where((v) => v.ownerId == user.uid).toList();
          final vegMap = {for (var v in userVeg) v.id: v};

          return FutureBuilder<List<Order>>(
            future: OrderService.listByVegetableIds(vegMap.keys.toList()),
            builder: (context, orderSnapshot) {
              if (!orderSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = orderSnapshot.data!;

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

                return FutureBuilder<UserProfile>(
                  future: UserService.getUserProfile(clientId),
                  builder: (context, snapshot) {
                    final clientData = snapshot.hasData
                        ? snapshot.data!.toMap()
                        : <String, dynamic>{};
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
                              OrderService.updateStatus(order.id, value);
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
