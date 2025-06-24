import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/user/user_model.dart';

import '../auth/auth_provider.dart';
import '../user/user_provider.dart';

class AccountReputationToggleSection extends StatelessWidget {
  const AccountReputationToggleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    if (user == null) return const SizedBox.shrink();

    final userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder<UserProfile?>(
      future: userProvider.getUser(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final userProfile = snapshot.data!;
        final optIn = userProfile.reputation?.optIn ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Autoriser les évaluations publiques"),
              subtitle: const Text(
                  "Permet aux autres de vous noter (réputation visible)"),
              value: optIn,
              onChanged: (enabled) async {
                await userProvider.setUserReputationOptIn(user.uid, enabled);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(enabled
                        ? "Réputation activée"
                        : "Réputation désactivée"),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                "En activant cette option, une note moyenne basée sur les évaluations reçues vous sera attribuée. "
                "Cette note sera visible sur votre profil public par les autres utilisateurs.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );
  }
}
