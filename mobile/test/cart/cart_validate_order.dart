import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/cart/cart_provider.dart';
import 'package:vegito/order/order_provider.dart';

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
    await orderProvider.validateCartOrders(
      user.uid,
      cart.items.map((vegetable, quantity) => MapEntry(vegetable.id, quantity)),
    );
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
