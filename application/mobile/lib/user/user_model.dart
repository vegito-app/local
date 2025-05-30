import 'package:cloud_firestore/cloud_firestore.dart';
import '../reputation/user_reputation.dart';

class UserProfile {
  final String id;
  final String? name;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final String? location;
  final String? phone;
  final String? address;
  final String? email;
  final String? password;
  final UserReputation reputation;

  UserProfile({
    required this.id,
    this.name,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.location,
    this.phone,
    this.address,
    this.email,
    this.password,
    required this.reputation,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'reputation': reputation.toMap(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String?,
      reputation: map['reputation'] != null
          ? UserReputation.fromMap(
              map['id'] as String, map['reputation'] as Map<String, dynamic>)
          : UserReputation.empty(
              userId: map['id'] as String,
            ),
    );
  }

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] as String?,
      email: data['email'] as String?,
      password: data['password'] as String?,
      reputation: data['reputation'] != null
          ? UserReputation.fromMap(
              doc.id, data['reputation'] as Map<String, dynamic>)
          : UserReputation.empty(
              userId: doc.id,
            ),
    );
  }
}
