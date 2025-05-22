import 'package:cloud_firestore/cloud_firestore.dart';

class VegetableOrderService {
  static Future<void> createOrder({
    required String vegetableId,
    required String clientId,
    required int quantity,
  }) async {
    await FirebaseFirestore.instance.collection('orders').add({
      'vegetableId': vegetableId,
      'clientId': clientId,
      'quantity': quantity,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot> getOrdersByClientId(String clientId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getOrdersByVegetableId(String vegetableId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('vegetableId', isEqualTo: vegetableId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
