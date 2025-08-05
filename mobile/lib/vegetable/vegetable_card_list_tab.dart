import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/user/user_model.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_model.dart';

import '../cart/cart_provider.dart';
import '../user/user_card.dart';
import '../user/user_provider.dart';

class VegetableCardListTab extends StatelessWidget {
  final List<Vegetable> vegetables;
  const VegetableCardListTab({super.key, required this.vegetables});

  @override
  Widget build(BuildContext context) {
    return Consumer<VegetableListProvider>(
      builder: (context, provider, _) {
        final vegetables = provider.vegetables;

        if (vegetables.isEmpty) {
          return const Center(child: Text('Aucun légume disponible.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vegetables.length,
          itemBuilder: (context, index) {
            final veg = vegetables[index];
            final imagePath =
                veg.images.isNotEmpty ? veg.images.first.publicUrl : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: imagePath != null
                          ? Image.network(imagePath,
                              width: 64, height: 64, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 64),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(veg.name),
                          Text(
                            veg.saleType == 'weight'
                                ? (veg.quantityAvailable < 1000
                                    ? 'Quantité disponible : ${veg.quantityAvailable} g'
                                    : 'Quantité disponible : ${(veg.quantityAvailable / 1000).toStringAsFixed(2)} Kg')
                                : 'Quantité disponible : ${veg.quantityAvailable.toInt()} unité(s)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        veg.saleType == 'weight'
                            ? '${veg.priceCents / 100}€ / Kg'
                            : '${veg.priceCents / 100}€ / unité',
                      ),
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
                    FutureBuilder<UserProfile?>(
                      future: Provider.of<UserProvider>(context, listen: false)
                          .getUser(veg.ownerId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox();
                        }
                        final profile = snapshot.data!;
                        final reputation = profile.reputation;

                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                          child: UserCard(
                            displayName: profile.name ?? 'Utilisateur',
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
    );
  }
}
