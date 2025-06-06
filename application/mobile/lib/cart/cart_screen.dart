import 'package:car2go/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cart/cart_provider.dart';
import '../order/order_service.dart';
import 'cart_validate_order.dart';

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
                  leading: veg.images.isNotEmpty
                      ? Image.network(
                          veg.images.first.url,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 64),
                  title: Text(veg.name),
                  subtitle: Text('$qty × ${veg.priceCents / 100}€'),
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
                  // await _validateOrders(context);
                  // Optionally, you can show a confirmation dialog before validating
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmer la commande'),
                      content: const Text(
                          'Êtes-vous sûr de vouloir valider les commandes ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Confirmer'),
                        ),
                      ],
                    ),
                  );
                  // If the user confirmed, proceed with order validation
                  // If the user cancelled, do nothing
                  if (confirm == true) {
                    await _validateOrders(context);
                  }
                },
                child: const Text('Valider les commandes'),
              ),
            )
          : null,
    );
  }
}

Future<void> _validateOrders(BuildContext context) async {
  await validateOrders(context);
}
