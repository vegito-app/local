import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stripe_service.dart';

class PaymentScreen extends StatelessWidget {
  final StripeService stripeService = StripeService();

  PaymentScreen({super.key});

  Future<void> _pay(BuildContext context) async {
    const testPriceId = 'price_1234567890'; // à remplacer dynamiquement

    try {
      final checkoutUrl =
          await stripeService.createCheckoutSession(testPriceId);
      if (checkoutUrl != null && await canLaunchUrl(Uri.parse(checkoutUrl))) {
        await launchUrl(Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’ouvrir Stripe')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pay(context),
          child: const Text('Payer avec carte'),
        ),
      ),
    );
  }
}
