import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cart/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../vegetable_upload/vegetable_model.dart';
import '../user/user_card.dart';
import '../reputation/user_reputation.dart';

class VegetableBuyerPage extends StatelessWidget {
  const VegetableBuyerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter des légumes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vegetables')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun légume disponible.'));
          }

          final vegetables =
              snapshot.data!.docs.map((doc) => Vegetable.fromDoc(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vegetables.length,
            itemBuilder: (context, index) {
              final veg = vegetables[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Image.network(
                          veg.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                        title: Text(veg.name),
                        subtitle: Text(
                            '${veg.weightGrams}g - ${veg.priceCents / 100}€'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .add(veg);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ajouté au panier')),
                            );
                          },
                          child: const Text('Ajouter au panier'),
                        ),
                      ),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(veg.userId)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final reputation =
                              UserReputation.fromMap(veg.userId, data);
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8),
                            child: UserCard(
                              displayName: data['displayName'] ?? 'Utilisateur',
                              reputation: reputation,
                            ),
                          );
                        },
                      ),
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
