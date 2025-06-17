import 'package:car2go/vegetable/vegetable_management_actions.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_photo_picker.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:car2go/vegetable/vegetable_submit_button.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
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

class _VegetableUploadFormState extends State<_VegetableUploadForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  // int weightGrams = 0;
  int priceCents = 0;

  SaleType saleType = SaleType.unit;

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  // late final TextEditingController weightController;
  late final TextEditingController priceController;

  late final TextEditingController quantityController;
  late final TextEditingController availabilityDateController;
  AvailabilityType availabilityType = AvailabilityType.sameDay;
  DateTime? availabilityDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VegetableUploadProvider>();
    nameController =
        TextEditingController(text: provider.initialVegetable?.name ?? '');
    descriptionController = TextEditingController(
        text: provider.initialVegetable?.description ?? '');
    // weightController = TextEditingController(
    //     text: provider.initialVegetable?.weightGrams != null
    //         ? provider.initialVegetable!.weightGrams.toString()
    //         : '');
    priceController = TextEditingController(
        text: provider.initialVegetable?.priceCents != null
            ? (provider.initialVegetable!.priceCents / 100).toStringAsFixed(2)
            : '');
    quantityController = TextEditingController(
      text: provider.initialVegetable?.quantityAvailable != null
          ? (provider.initialVegetable!.quantityAvailable / 1000)
              .toStringAsFixed(3)
          : '',
    );
    availabilityDateController = TextEditingController();

    if (provider.initialVegetable?.saleType == 'weight') {
      saleType = SaleType.weight;
    }
    if (provider.initialVegetable?.availabilityType == 'futureDate') {
      availabilityType = AvailabilityType.futureDate;
    } else if (provider.initialVegetable?.availabilityType ==
        'alreadyHarvested') {
      availabilityType = AvailabilityType.alreadyHarvested;
    } else {
      availabilityType = AvailabilityType.sameDay;
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
            VegetableManagementActions(
              provider: provider,
            ),
            const SizedBox(height: 12),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              value: SaleType.weight,
                              child: Text("Au poids (€/kg)")),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Disponibilité",
                          style: Theme.of(context).textTheme.titleMedium),
                      DropdownButton<AvailabilityType>(
                        key: const Key("availabilityTypeDropdown"),
                        value: availabilityType,
                        onChanged: (AvailabilityType? newValue) async {
                          if (newValue != null) {
                            DateTime? pickedDate;
                            final now = DateTime.now();
                            if (newValue == AvailabilityType.futureDate) {
                              pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now.add(const Duration(days: 1)),
                                firstDate: now.add(const Duration(days: 1)),
                                lastDate: now.add(const Duration(days: 365)),
                              );
                            } else if (newValue ==
                                AvailabilityType.alreadyHarvested) {
                              pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate:
                                    now.subtract(const Duration(days: 365)),
                                lastDate: now,
                              );
                            }

                            setState(() {
                              availabilityType = newValue;
                              if (newValue == AvailabilityType.sameDay ||
                                  pickedDate == null) {
                                availabilityDate = null;
                                availabilityDateController.clear();
                              } else {
                                availabilityDate = pickedDate;
                                availabilityDateController.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                              }
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                              value: AvailabilityType.sameDay,
                              child: Text("Récolté le jour même")),
                          DropdownMenuItem(
                              value: AvailabilityType.futureDate,
                              child: Text("Récolte à venir")),
                          DropdownMenuItem(
                              value: AvailabilityType.alreadyHarvested,
                              child: Text("Déjà récolté")),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VegetableSaleDetailsSection(
                nameController: nameController,
                descriptionController: descriptionController,
                // weightController: weightController,
                priceController: priceController,
                quantityController: quantityController,
                saleType: saleType,
                availabilityType: availabilityType,
                availabilityDate: availabilityDate),
            const SizedBox(height: 20),
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Semantics(
                      label: 'submit-vegetable-button',
                      button: true,
                      child: VegetableSubmitButton(
                        formKey: _formKey,
                        availabilityType: availabilityType,
                        availabilityDate: availabilityDate,
                        nameController: nameController,
                        descriptionController: descriptionController,
                        // weightController: weightController,
                        priceController: priceController,
                        quantityController: quantityController,
                        saleType: saleType,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
