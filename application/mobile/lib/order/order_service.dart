import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

import 'order_model.dart';

class OrderService {
  final http.Client client;
  final String backendUrl;

  OrderService({http.Client? client, String? backendUrl})
      : client = client ?? http.Client(),
        backendUrl = backendUrl ?? Config.backendUrl;

  Future<void> createOrder({
    required String vegetableId,
    required String clientId,
    required int quantity,
  }) async {
    final url = Uri.parse('$backendUrl/api/orders');
    await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vegetableId': vegetableId,
        'clientId': clientId,
        'quantity': quantity,
      }),
    );
  }

  Future<List<Order>> listByVegetableIds(List<String> vegetableIds) async {
    final url = Uri.parse('$backendUrl/api/orders/search');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'vegetableIds': vegetableIds}),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération des commandes');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateStatus(String orderId, String status) async {
    final url = Uri.parse('$backendUrl/api/orders/$orderId');
    await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
  }

  Future<List<Order>> listByClientId(String clientId) async {
    final url = Uri.parse('$backendUrl/api/orders/client/$clientId');
    final response = await client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération des commandes');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrder(String orderId) async {
    final url = Uri.parse('$backendUrl/api/orders/$orderId');
    final response = await client.get(url);

    if (response.statusCode == 404) {
      throw Exception('Commande non trouvée');
    }
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la récupération de la commande');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Order.fromMap(data);
  }

  Future<void> deleteOrder(String orderId) async {
    final url = Uri.parse('$backendUrl/api/orders/$orderId');
    final response = await client.delete(url);

    if (response.statusCode == 404) {
      throw Exception('Commande non trouvée');
    }
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la commande');
    }
  }
}
