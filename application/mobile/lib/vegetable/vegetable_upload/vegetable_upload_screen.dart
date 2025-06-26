import 'package:vegito/vegetable/vegetable_management_actions.dart';
import 'package:vegito/vegetable/vegetable_map/vegetable_map_location_picker.dart';
import 'package:vegito/vegetable/vegetable_model.dart';
import 'package:vegito/vegetable/vegetable_photo_picker.dart';
import 'package:vegito/vegetable/vegetable_service.dart';
import 'package:vegito/vegetable/vegetable_submit_button.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late final TextEditingController priceController;

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
    priceController = TextEditingController(
        text: provider.initialVegetable?.priceCents != null
            ? (provider.initialVegetable!.priceCents / 100).toStringAsFixed(2)
            : '');
    availabilityDateController = TextEditingController();

    priceController.addListener(() {
      final provider = context.read<VegetableUploadProvider>();
      final parsed = double.tryParse(priceController.text.replaceAll(',', '.'));
      if (parsed != null) {
        provider.priceEuros = parsed;
      }
    });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VegetableUploadProvider>();

      final parsedPrice =
          double.tryParse(priceController.text.replaceAll(',', '.'));
      if (parsedPrice != null) {
        provider.priceEuros = parsedPrice;
      }

      provider.saleType = saleType.name;
    });
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
            Text("Livraison", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Semantics(
              label: 'location-picker-button',
              button: true,
              child: TextButton.icon(
                key: const Key("chooseLocation"),
                onPressed: () async {
                  final provider = context.read<VegetableUploadProvider>();
                  final selected = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VegetableMapLocationPicker(
                        onLocationSelected: (pos) =>
                            Navigator.pop(context, pos),
                      ),
                    ),
                  );
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
            ),
            const SizedBox(height: 20),
            Text("Détails du légume",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            VegetableSaleDetailsSection(
                nameController: nameController,
                descriptionController: descriptionController,
                priceController: priceController,
                initialSaleType: saleType,
                initialAvailabilityType: availabilityType,
                initialAvailabilityDate: availabilityDate,
                availabilityDateController: availabilityDateController,
                onSaleTypeChanged: (type) {
                  setState(() {
                    saleType = type;
                    provider.saleType = type.name;
                  });
                },
                onAvailabilityChanged: (type, date) {
                  setState(() {
                    availabilityType = type;
                    availabilityDate = date;
                    provider.availabilityType = type;
                    provider.availabilityDate = date;
                  });
                },
                isNewVegetable: provider.initialVegetable == null),
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
                        priceController: priceController,
                        saleType: saleType,
                        latitude: provider.deliveryLocation?.latitude ?? 0.0,
                        longitude: provider.deliveryLocation?.longitude ?? 0.0,
                        deliveryRadiusKm: provider.deliveryRadiusKm,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
