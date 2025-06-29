// vegetable_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vegito/vegetable/vegetable_management_actions.dart';
import 'package:vegito/vegetable/vegetable_map/vegetable_map_location_picker.dart';
import 'package:vegito/vegetable/vegetable_model.dart';
import 'package:vegito/vegetable/vegetable_photo_picker.dart';
import 'package:vegito/vegetable/vegetable_service.dart';
import 'package:vegito/vegetable/vegetable_submit_button.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';

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
          title: Text(
            vegetable == null ? 'Ajouter un légume' : 'Modifier un légume',
          ),
        ),
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
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController availableQuantityController;
  late final TextEditingController availabilityDateController;
  late final TextEditingController deliveryRadiusKmController;
  late final TextEditingController deliveryLocationController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VegetableUploadProvider>();
    final initial = provider.initialVegetable;

    nameController = TextEditingController(text: initial?.name ?? '');
    descriptionController =
        TextEditingController(text: initial?.description ?? '');
    priceController = TextEditingController(
      text: initial?.priceCents != null
          ? (initial!.priceCents / 100).toStringAsFixed(2)
          : '',
    );
    availableQuantityController = TextEditingController(
      text: initial?.quantityAvailable.toString() ?? '0',
    );
    availabilityDateController = TextEditingController(
      text: initial?.availabilityDate?.toIso8601String().split('T').first ?? '',
    );

    deliveryRadiusKmController = TextEditingController(
      text: initial?.deliveryRadiusKm?.toStringAsFixed(1) ?? '0.0',
    );
    deliveryLocationController = TextEditingController(
      text: initial?.deliveryLocation != null
          ? '${initial!.deliveryLocation!.latitude.toString()}, ${initial.deliveryLocation!.longitude.toString()}'
          : '',
    );

    // IMPORTANT: Synchroniser les valeurs initiales avec le provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialValuesToProvider();
    });

    // Ajouter les listeners pour les changements futurs
    nameController.addListener(() {
      provider.name = nameController.text;
    });

    descriptionController.addListener(() {
      provider.description = descriptionController.text;
    });

    priceController.addListener(() {
      final parsed = double.tryParse(priceController.text.replaceAll(',', '.'));
      if (parsed != null) {
        provider.priceEuros = parsed;
      }
    });

    availabilityDateController.addListener(() {
      final date = availabilityDateController.text;
      if (date.isNotEmpty) {
        final parsedDate = DateTime.tryParse(date);
        provider.availabilityDate = parsedDate;
      } else {
        provider.availabilityDate = null;
      }
    });
  }

  void _syncInitialValuesToProvider() {
    final provider = context.read<VegetableUploadProvider>();

    // Synchroniser toutes les valeurs initiales
    if (nameController.text.isNotEmpty) {
      provider.name = nameController.text;
    }

    if (descriptionController.text.isNotEmpty) {
      provider.description = descriptionController.text;
    }

    if (priceController.text.isNotEmpty) {
      final parsed = double.tryParse(priceController.text.replaceAll(',', '.'));
      if (parsed != null) {
        provider.priceEuros = parsed;
      }
    }

    if (availableQuantityController.text.isNotEmpty) {
      final parsed = int.tryParse(availableQuantityController.text);
      if (parsed != null) {
        provider.quantityAvailable = parsed;
      }
    }

    if (availabilityDateController.text.isNotEmpty) {
      final parsedDate = DateTime.tryParse(availabilityDateController.text);
      if (parsedDate != null) {
        provider.availabilityDate = parsedDate;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    availableQuantityController.dispose();
    availabilityDateController.dispose();
    deliveryRadiusKmController.dispose();
    deliveryLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VegetableUploadProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VegetableManagementActions(provider: provider),
            const SizedBox(height: 12),
            Text("Informations générales",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      VegetablePhotoPicker(provider: provider),
                      if (provider.images.length < 3)
                        TextButton.icon(
                          key: const Key("chooseImage"),
                          onPressed: provider.pickImage,
                          icon: const Icon(Icons.photo),
                          label: Text(provider.images.isEmpty
                              ? 'Choisir une photo'
                              : 'Ajouter une photo'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: TextButton.icon(
                    key: const Key("chooseLocation"),
                    onPressed: () async {
                      final selected = await Navigator.push<LatLng>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VegetableMapLocationPicker(
                            initialLocation: provider.deliveryLocation,
                            onLocationSelected: (pos) =>
                                Navigator.pop(context, pos),
                          ),
                        ),
                      );
                      if (!mounted) return;
                      if (selected != null) {
                        provider.deliveryLocation = selected;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Position définie')),
                        );
                      }
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Définir la position de livraison'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Text("Détails du légume",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            VegetableSaleDetailsSection(
              nameController: nameController,
              descriptionController: descriptionController,
              priceController: priceController,
              // initialSaleType: provider.saleType,
              // initialAvailabilityType: provider.availabilityType,
              availabilityDateController: availabilityDateController,
              quantityController: availableQuantityController,
              // initialQuantity:
              //     provider.initialVegetable?.quantityAvailable ?? 0,
              // availabilityDateController: availabilityDateController,
              // onSaleTypeChanged: (type) {
              //   setState(() {
              //     provider.saleType = type;
              //     provider.saleType = type;
              //   });
              // },
              // onAvailabilityChanged: (type, date) {
              //   setState(() {
              //     provider.availabilityType = type;
              //     provider.availabilityDate = date;
              //     provider.availabilityType = type;
              //     provider.availabilityDate = date;
              //   });
              // },
              // onQuantityChanged: (quantity) {
              //   provider.quantityAvailable = quantity;
              //   availableQuantityController.text = quantity.toString();
              // },
              isNewVegetable: provider.initialVegetable == null,
            ),
            const SizedBox(height: 20),
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: VegetableSubmitButton(
                      formKey: _formKey,
                      provider: provider,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
