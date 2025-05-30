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

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      vegetableId: map['vegetableId'] as String,
      clientId: map['clientId'] as String,
      quantity: map['quantity'] as int,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
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
