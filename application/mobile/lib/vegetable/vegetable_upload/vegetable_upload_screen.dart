import 'dart:io';

import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_provider.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:car2go/vegetable/vegetable_upload/form/vegetable_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vegetable_upload_provider.dart';

class VegetableUploadScreen extends StatelessWidget {
  final VegetableService? service;

  const VegetableUploadScreen({super.key, this.service});
  @override
  Widget build(BuildContext context) {
    final vegetable = ModalRoute.of(context)?.settings.arguments as Vegetable?;

    return ChangeNotifierProvider(
      create: (_) => vegetable == null
          ? VegetableUploadProvider(service: service)
          : VegetableUploadProvider.fromVegetable(vegetable, service: service),
      child: Scaffold(
        appBar: AppBar(
            title: Text(vegetable == null
                ? 'Ajouter un légume'
                : 'Modifier un légume')),
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

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController weightController;
  late final TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VegetableUploadProvider>();
    nameController =
        TextEditingController(text: provider.initialVegetable?.name ?? '');
    descriptionController = TextEditingController(
        text: provider.initialVegetable?.description ?? '');
    weightController = TextEditingController(
        text: provider.initialVegetable?.weightGrams != null
            ? provider.initialVegetable!.weightGrams.toString()
            : '');
    priceController = TextEditingController(
        text: provider.initialVegetable?.priceCents != null
            ? provider.initialVegetable!.priceCents.toString()
            : '');
    if (provider.initialVegetable?.saleType == 'weight') {
      saleType = SaleType.weight;
    }
  }

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
              VegetablePhotoPicker(provider: provider),
            Semantics(
              label: 'image-picker-button',
              button: true,
              child: TextButton.icon(
                key: const Key("chooseImage"),
                onPressed: provider.pickImage,
                icon: const Icon(Icons.photo),
                label: Text(provider.images.isEmpty
                    ? 'Choisir une photo'
                    : 'Ajouter une photo'),
              ),
            ),
            const SizedBox(height: 20),
            Text("Détails du légume",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text("Type de vente",
                style: Theme.of(context).textTheme.titleMedium),
            Semantics(
              label: 'dropdown-sale-type',
              child: DropdownButton<SaleType>(
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
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'input-name',
              child: TextFormField(
                key: const Key("nameField"),
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Obligatoire' : null,
              ),
            ),
            Semantics(
              label: 'input-description',
              child: TextFormField(
                key: const Key("descriptionField"),
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ),
            if (saleType == SaleType.weight)
              Semantics(
                label: 'input-weight',
                child: TextFormField(
                  key: const Key("weightField"),
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Poids (g)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            Semantics(
              label: 'input-price',
              child: TextFormField(
                key: const Key("priceField"),
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix (centimes)'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Semantics(
                      label: 'submit-vegetable-button',
                      button: true,
                      child: ElevatedButton(
                        key: const Key("submitButton"),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();

                          name = nameController.text;
                          description = descriptionController.text;
                          weightGrams =
                              int.tryParse(weightController.text) ?? 0;
                          priceCents = int.tryParse(priceController.text) ?? 0;

                          try {
                            final authProvider = context.read<AuthProvider>();
                            final vegetableProvider =
                                context.read<VegetableProvider>();
                            await provider.submitVegetable(
                              userId: authProvider.user!.uid,
                              vegetableProvider: vegetableProvider,
                              name: name,
                              description: description,
                              weightGrams: weightGrams,
                              priceCents: priceCents,
                              saleType:
                                  saleType == SaleType.unit ? 'unit' : 'weight',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Semantics(
                                    label: 'vegetable-upload-success',
                                    child:
                                        const Text('Légume ajouté avec succès'),
                                  ),
                                ),
                              );
                              Navigator.pop(context, true);
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
                  ),
          ],
        ),
      ),
    );
  }
}
