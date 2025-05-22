import 'package:car2go/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cart/cart_provider.dart';
import '../order/order_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: items.isEmpty
          ? const Center(child: Text('Votre panier est vide.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: items.entries.map((entry) {
                final veg = entry.key;
                final qty = entry.value;
                return ListTile(
                  leading: Image.network(veg.imageUrl, width: 64, height: 64),
                  title: Text(veg.name),
                  subtitle: Text('${qty} × ${veg.priceCents / 100}€'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => cart.remove(veg),
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: items.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.user;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vous devez être connecté')),
                    );
                    return;
                  }

                  for (final entry in items.entries) {
                    await VegetableOrderService.createOrder(
                      vegetableId: entry.key.id,
                      clientId: user.uid,
                      quantity: entry.value,
                    );
                  }

                  cart.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Commandes envoyées !')),
                  );

                  Navigator.pop(context);
                },
                child: const Text('Valider les commandes'),
              ),
            )
          : null,
    );
  }
}
