import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

import 'order_model.dart';

const backendUrl = Config.backendUrl;

class OrderService {
  static Future<void> createOrder({
    required String vegetableId,
    required String clientId,
    required int quantity,
  }) async {
    final url = Uri.parse('$backendUrl/orders');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vegetableId': vegetableId,
        'clientId': clientId,
        'quantity': quantity,
      }),
    );
  }

  static Future<List<Order>> listByVegetableIds(
      List<String> vegetableIds) async {
    final idsParam = vegetableIds.join(',');
    final url = Uri.parse('$backendUrl/orders?vegetableIds=$idsParam');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération des commandes');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<void> updateStatus(String orderId, String status) async {
    final url = Uri.parse('$backendUrl/orders/$orderId');
    await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
  }

  static Future<List<Order>> listByClientId(String clientId) async {
    final url = Uri.parse('$backendUrl/orders?clientId=$clientId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Échec lors de la récupération des commandes');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
  }
}
