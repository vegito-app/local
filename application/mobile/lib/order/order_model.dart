import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String vegetableId;
  final String clientId;
  final int quantity;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.vegetableId,
    required this.clientId,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'vegetableId': vegetableId,
      'clientId': clientId,
      'quantity': quantity,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Order.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      vegetableId: data['vegetableId'] as String,
      clientId: data['clientId'] as String,
      quantity: data['quantity'] as int,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
