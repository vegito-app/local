import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../reputation/user_reputation.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil utilisateur")),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final reputation = UserReputation.fromMap(userId, data);
          final displayName = data['displayName'] ?? 'Utilisateur';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 30, child: Icon(Icons.person, size: 30)),
                    const SizedBox(width: 16),
                    Text(displayName,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 24),
                if (reputation.optIn)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        "${reputation.score.toStringAsFixed(1)} / 5",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      Text("(${reputation.votes} votes)",
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("Réputation non publique"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
