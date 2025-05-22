import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reputation/user_reputation.dart';
import '../user/user_card.dart';
import '../vegetable_upload/vegetable_model.dart';
import 'order_model.dart';

class OrderCard extends StatelessWidget {
  final Vegetable vegetable;
  final Order order;
  final ValueChanged<String> onStatusChanged;

  const OrderCard({
    super.key,
    required this.vegetable,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabels = {
      'pending': 'À préparer',
      'prepared': 'Récolté',
      'loaded': 'Chargé',
      'delivered': 'Livré',
    };

    final statuses = ['pending', 'prepared', 'loaded', 'delivered'];

    const steps = ['pending', 'prepared', 'loaded', 'delivered'];

    Widget buildTimeline(String current) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.map((step) {
          final isActive = steps.indexOf(step) <= steps.indexOf(current);
          return Column(
            children: [
              Icon(
                isActive
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: isActive ? Colors.green : Colors.grey,
              ),
              Text(statusLabels[step]!, style: const TextStyle(fontSize: 10)),
            ],
          );
        }).toList(),
      );
    }

    Widget buildSellerCard() {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(vegetable.userId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final reputation = UserReputation.fromMap(vegetable.userId, data);
          return UserCard(
            displayName: data['displayName'] ?? 'Utilisateur',
            reputation: reputation,
          );
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  vegetable.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${vegetable.name} x${order.quantity}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            buildSellerCard(),
            const SizedBox(height: 8),
            Text(
              'Statut : ${statusLabels[order.status] ?? order.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            buildTimeline(order.status),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: statuses
                  .map((status) => ChoiceChip(
                        label: Text(statusLabels[status]!),
                        selected: order.status == status,
                        onSelected: (_) => onStatusChanged(status),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
