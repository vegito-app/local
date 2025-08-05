import 'package:cloud_firestore/cloud_firestore.dart';
import '../reputation/user_reputation.dart';

class UserProfile {
  final String id;
  final bool anonymous;
  final String? name;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final String? location;
  final String? phone;
  final String? address;
  final String? email;
  final String? password;
  final UserReputation? reputation;

  UserProfile({
    required this.id,
    required this.anonymous,
    this.name,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.location,
    this.phone,
    this.address,
    this.email,
    this.password,
    this.reputation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'email': email,
      'anonymous': anonymous,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String?,
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      anonymous: map['anonymous'] as bool? ?? false,
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
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      anonymous: data['anonymous'] as bool? ?? false,
      reputation: data['reputation'] != null
          ? UserReputation.fromMap(
              doc.id, data['reputation'] as Map<String, dynamic>)
          : UserReputation.empty(
              userId: doc.id,
            ),
    );
  }
}
