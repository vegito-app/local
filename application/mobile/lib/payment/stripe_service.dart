import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vegito/config.dart';
import 'package:vegito/http/auth_headers.dart';

class StripeService {
  final http.Client client;
  final String backendUrl;

  StripeService({http.Client? client, String? backendUrl})
      : client = client ?? http.Client(),
        backendUrl = backendUrl ?? Config.backendUrl;

  Future<String?> createCheckoutSession(String priceId) async {
    final response = await client.post(
      Uri.parse('$backendUrl/api/payments/create-checkout-session'),
      headers: await authHeaders(),
      body: json.encode({'priceId': priceId}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      return data['checkoutUrl'] as String?;
    } else {
      throw Exception('Échec de la création de la session Stripe');
    }
  }
}
