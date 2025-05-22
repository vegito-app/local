import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vegetable_upload_provider.dart';

class VegetableUploadScreen extends StatelessWidget {
  const VegetableUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VegetableUploadProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajouter un légume')),
        body: const _VegetableUploadForm(),
      ),
    );
  }
}

class _VegetableUploadForm extends StatefulWidget {
  const _VegetableUploadForm();

  @override
  State<_VegetableUploadForm> createState() => _VegetableUploadFormState();
}

class _VegetableUploadFormState extends State<_VegetableUploadForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  int weightGrams = 0;
  int priceCents = 0;

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<VegetableUploadProvider>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (provider.image != null)
              Image.file(
                File(provider.image!.path),
                height: 150,
              ),
            TextButton.icon(
              onPressed: provider.pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('Choisir une photo'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onSaved: (val) => name = val ?? '',
              validator: (val) =>
                  val == null || val.isEmpty ? 'Obligatoire' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (val) => description = val ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Poids (g)'),
              keyboardType: TextInputType.number,
              onSaved: (val) => weightGrams = int.tryParse(val ?? '') ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Prix (centimes)'),
              keyboardType: TextInputType.number,
              onSaved: (val) => priceCents = int.tryParse(val ?? '') ?? 0,
            ),
            const SizedBox(height: 20),
            provider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      _formKey.currentState!.save();
                      try {
                        await provider.submitVegetable(
                          context: context,
                          name: name,
                          description: description,
                          weightGrams: weightGrams,
                          priceCents: priceCents,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Légume ajouté !')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : $e')),
                        );
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
          ],
        ),
      ),
    );
  }
}
