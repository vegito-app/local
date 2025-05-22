import 'package:cloud_firestore/cloud_firestore.dart';

class Vegetable {
  final String id;
  final String name;
  final String description;
  final int weightGrams;
  final int priceCents;
  final String imageUrl;
  final String ownerId;
  final DateTime createdAt;

  Vegetable({
    required this.id,
    required this.name,
    required this.description,
    required this.weightGrams,
    required this.priceCents,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'weightGrams': weightGrams,
      'priceCents': priceCents,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Vegetable.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
 

    return Vegetable(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      weightGrams: (data['weightGrams'] ?? 0) as int,
      priceCents: (data['priceCents'] ?? 0) as int,
      imageUrl: (data['imageUrl'] ?? '') as String,
      ownerId: (data['ownerId'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
