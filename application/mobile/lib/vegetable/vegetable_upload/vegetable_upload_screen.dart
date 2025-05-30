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

enum SaleType { unit, weight }

class _VegetableUploadFormState extends State<_VegetableUploadForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  int weightGrams = 0;
  int priceCents = 0;

  SaleType saleType = SaleType.unit;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VegetableUploadProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informations générales",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (provider.images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Photos sélectionnées :"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.images
                        .asMap()
                        .entries
                        .map(
                          (entry) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: entry.key == provider.mainImageIndex
                                        ? Colors.green
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: Image.file(
                                  File(entry.value.path),
                                  height: 100,
                                ),
                              ),
                              if (entry.key != provider.mainImageIndex)
                                IconButton(
                                  icon: const Icon(Icons.star_border),
                                  onPressed: () =>
                                      provider.setMainImage(entry.key),
                                  tooltip: "Définir comme principale",
                                ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Semantics(
                                  label: 'Supprimer photo ${entry.key + 1}',
                                  hint: 'Supprimer cette photo',
                                  excludeSemantics: true,
                                  button: true,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    tooltip: 'Supprimer cette photo',
                                    //
                                    onPressed: () =>
                                        provider.removeImage(entry.key),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            TextButton.icon(
              key: const Key("chooseImage"),
              onPressed: provider.pickImage,
              icon: const Icon(Icons.photo),
              label: Text(provider.images.isEmpty
                  ? 'Choisir une photo'
                  : 'Ajouter une photo'),
            ),
            const SizedBox(height: 20),
            Text("Détails du légume",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text("Type de vente",
                style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<SaleType>(
              key: const Key("saleTypeDropdown"),
              value: saleType,
              onChanged: (SaleType? newValue) {
                if (newValue != null) {
                  setState(() {
                    saleType = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                    value: SaleType.unit, child: Text("À l’unité")),
                DropdownMenuItem(
                    value: SaleType.weight, child: Text("Au poids (€/kg)")),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key("nameField"),
              decoration: const InputDecoration(labelText: 'Nom'),
              onSaved: (val) => name = val ?? '',
              validator: (val) =>
                  val == null || val.isEmpty ? 'Obligatoire' : null,
            ),
            TextFormField(
              key: const Key("descriptionField"),
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (val) => description = val ?? '',
            ),
            if (saleType == SaleType.weight)
              TextFormField(
                key: const Key("weightField"),
                decoration: const InputDecoration(labelText: 'Poids (g)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => weightGrams = int.tryParse(val ?? '') ?? 0,
              ),
            TextFormField(
              key: const Key("priceField"),
              decoration: const InputDecoration(labelText: 'Prix (centimes)'),
              keyboardType: TextInputType.number,
              onSaved: (val) => priceCents = int.tryParse(val ?? '') ?? 0,
            ),
            const SizedBox(height: 20),
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ElevatedButton(
                      key: const Key("submitButton"),
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
                            saleType:
                                saleType == SaleType.unit ? 'unit' : 'weight',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Légume ajouté avec succès')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
