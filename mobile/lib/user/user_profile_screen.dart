import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../reputation/user_reputation.dart';
import 'user_provider.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Profil utilisateur")),
      body: FutureBuilder<void>(
        future: userProvider.loadUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userProfile = userProvider.getCurrentUser(userId);
          if (userProfile == null) {
            return const Center(child: Text("Utilisateur non trouvé"));
          }

          final reputation =
              UserReputation.fromMap(userId, userProfile.toMap());
          final displayName = userProfile.displayName ?? 'Utilisateur';

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
