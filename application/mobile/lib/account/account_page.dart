import 'package:car2go/account/account_validate.dart';
import 'package:car2go/auth/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../activity_screen.dart';
import '../auth/auth_security_banner.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _balance = "Chargement...";

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      await _initializeWallet();
    }
  }

  Future<void> _initializeWallet() async {
    setState(() {
      _balance = "0.00 BTC"; // Simuler le solde
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthSecurityBanner(contextType: AuthContext.account),
            const SizedBox(height: 20),
            const Text("Solde :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(_balance,
                style: const TextStyle(fontSize: 20, color: Colors.blue)),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(builder: (context, authProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statut de connexion :",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    authProvider.isAuthenticated ? "Connecté" : "Non connecté",
                    style: TextStyle(
                      fontSize: 20,
                      color: authProvider.isAuthenticated
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Adresse e-mail :",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(authProvider.user?.email ?? "Non disponible",
                          style: const TextStyle(
                              fontSize: 20, color: Colors.blue)),
                    ],
                  );
                }
                return const Text("Aucune adresse e-mail disponible.",
                    style: TextStyle(fontSize: 20, color: Colors.red));
              },
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(builder: (context, authProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statut de sécurité :",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    authProvider.isAuthenticated ? "Sécurisé" : "Non sécurisé",
                    style: TextStyle(
                      fontSize: 20,
                      color: authProvider.isAuthenticated
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  // ],
                  // );
                  if (authProvider.isAuthenticated) ...[
                    const Text("Statut de sécurité :",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      authProvider.isAnonymous ? "Anonyme" : "Sécurisé",
                      style: TextStyle(
                        fontSize: 20,
                        color: authProvider.isAnonymous
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                  if (authProvider.isAnonymous == true) ...[
                    const SizedBox(height: 10),
                    const AccountValidate(),
                  ],
                  const SizedBox(height: 20),
                  const Text("Profil public",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: authProvider.user?.displayName ?? "",
                    decoration: const InputDecoration(
                      labelText: "Nom public (affiché dans les commandes)",
                    ),
                    onFieldSubmitted: (value) async {
                      final uid = authProvider.user?.uid;
                      if (uid != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .set(
                          {
                            "displayName": value.trim(),
                          },
                          SetOptions(merge: true),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Nom public mis à jour")),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (authProvider.user != null) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(authProvider.user!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>? ??
                                {};
                        final optIn = data["reputationOptIn"] == true;
                        return SwitchListTile(
                          title:
                              const Text("Autoriser les évaluations publiques"),
                          subtitle: const Text(
                              "Permet aux autres de vous noter (réputation visible)"),
                          value: optIn,
                          onChanged: (enabled) async {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(authProvider.user!.uid)
                                .set(
                              {"reputationOptIn": enabled},
                              SetOptions(merge: true),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(enabled
                                    ? "Réputation activée"
                                    : "Réputation désactivée"),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _initializeWallet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Données rafraîchies.')),
                      );
                    },
                    child: const Text("Rafraîchir"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timeline),
                    label: const Text("Mon activité"),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ActivityScreen()),
                      );
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
