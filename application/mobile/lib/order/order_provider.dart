import 'package:car2go/order/order_model.dart';
import 'package:car2go/order/order_service.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service;
  List<Order> _orders = [];
  bool _loading = false;

  OrderProvider({OrderService? service}) : _service = service ?? OrderService();

  List<Order> get orders => _orders;
  bool get isLoading => _loading;

  Future<void> loadOrdersForUser(String userId) async {
    _loading = true;
    notifyListeners();
    _orders = await _service.listByClientId(userId);
    _loading = false;
    notifyListeners();
  }

  Future<void> validateCartOrders(
      String clientId, Map<String, int> cartItems) async {
    for (final entry in cartItems.entries) {
      await _service.createOrder(
        vegetableId: entry.key,
        clientId: clientId,
        quantity: entry.value,
      );
    }
  }

  Future<List<Order>> loadOrdersByVegetableIds(List<String> vegetableIds) {
    return _service.listByVegetableIds(vegetableIds);
  }

  Future<void> updateOrderStatus(String orderId, String status) {
    return _service.updateStatus(orderId, status);
  }
}
