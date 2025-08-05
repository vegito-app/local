import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../cart/cart_provider.dart';
import '../order/order_provider.dart';

Future<void> validateOrders(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final cart = Provider.of<CartProvider>(context, listen: false);
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  final user = authProvider.user;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vous devez être connecté')),
    );
    return;
  }

  try {
    final Map<String, int> itemsAsStringKey = cart.items
        .map((vegetable, quantity) => MapEntry(vegetable.id, quantity));
    await orderProvider.validateCartOrders(user.uid, itemsAsStringKey);
    cart.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commandes envoyées !')),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e')),
    );
  }
}
