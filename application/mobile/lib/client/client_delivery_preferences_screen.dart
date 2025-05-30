import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
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

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
          data,
          SetOptions(merge: true),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Préférences enregistrées.")),
      );
    }

    setState(() => _isSaving = false);
  }

  Future<void> _loadPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return;

    setState(() {
      _addressController.text = data['address'] as String;
      _shareLocation = data.containsKey('location');
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
