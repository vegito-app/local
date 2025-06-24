import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';

import '../user/user_provider.dart';

class ClientDeliveryPreferencesScreen extends StatefulWidget {
  const ClientDeliveryPreferencesScreen({super.key});

  @override
  State<ClientDeliveryPreferencesScreen> createState() =>
      _ClientDeliveryPreferencesScreenState();
}

class _ClientDeliveryPreferencesScreenState
    extends State<ClientDeliveryPreferencesScreen> {
  final _addressController = TextEditingController();
  bool _shareLocation = false;
  bool _isSaving = false;

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final uid = user?.uid;
    if (uid == null) return;

    final Map<String, dynamic> data = {
      'address': _addressController.text.trim(),
    };

    if (_shareLocation) {
      final position = await Geolocator.getCurrentPosition();
      data['location'] = {
        'lat': position.latitude,
        'lng': position.longitude,
      };
    }

    // Utiliser userProvider pour mettre à jour
    await userProvider.updateUserAddress(uid, data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Préférences enregistrées.")),
      );
    }

    setState(() => _isSaving = false);
  }

  Future<void> _loadPreferences() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final uid = user?.uid;
    if (uid == null) return;

    final userProfile = await userProvider.getUser(uid);
    if (userProfile == null) return;

    setState(() {
      _addressController.text = userProfile.address ?? "";
      _shareLocation = userProfile.location != null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Préférences de livraison")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Adresse postale (optionnelle)",
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Partager ma position GPS"),
              value: _shareLocation,
              onChanged: (val) {
                setState(() => _shareLocation = val);
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator())
                  : const Icon(Icons.save),
              label: const Text("Enregistrer"),
              onPressed: _isSaving ? null : _savePreferences,
            )
          ],
        ),
      ),
    );
  }
}
