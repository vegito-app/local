import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

class VegetableSubmitButton extends StatelessWidget {
  const VegetableSubmitButton({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.saleType,
    required this.availabilityType,
    required this.availabilityDate,
    required this.latitude,
    required this.longitude,
    required this.deliveryRadiusKm,
  });
  final GlobalKey<FormState> formKey;
  final AvailabilityType availabilityType;
  final DateTime? availabilityDate;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;

  final SaleType saleType;

  final double? latitude;
  final double? longitude;
  final double? deliveryRadiusKm;

  @override
  Widget build(BuildContext context) {
    // Planifie la mise à jour du saleType après le build pour éviter les erreurs setState pendant le build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VegetableUploadProvider>();
      provider.saleType = saleType.name;
    });

    return Semantics(
      label: 'submit-vegetable-button',
      button: true,
      child: Consumer<VegetableUploadProvider>(builder: (context, provider, _) {
        return ElevatedButton(
          key: const Key("submitButton"),
          onPressed: provider.isReadyToSubmit
              ? () async {
                  if (!formKey.currentState!.validate()) return;
                  formKey.currentState!.save();

                  final priceCents = int.tryParse(priceController.text) ?? 0;
                  final quantity = provider.quantityAvailable;
                  try {
                    final authProvider = context.read<AuthProvider>();
                    final vegetableListProvider =
                        context.read<VegetableListProvider>();
                    provider.priceEuros =
                        double.tryParse(priceController.text) ?? 0.0;
                    provider.availabilityType = availabilityType;
                    provider.availabilityDate = availabilityDate;
                    provider.saleType = saleType
                        .toString(); // Ensure saleType is set in provider
                    await provider.submitVegetable(
                      userId: authProvider.user!.uid,
                      vegetableListProvider: vegetableListProvider,
                      name: nameController.text,
                      description: descriptionController.text,
                      quantityAvailable: quantity,
                      priceCents: priceCents,
                      availabilityType: availabilityType,
                      availabilityDate: availabilityDate,
                      saleType: saleType.name,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Semantics(
                            label: 'vegetable-upload-success',
                            child: const Text('Légume enregistré avec succès'),
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
                }
              : null,
          child: const Text('Enregistrer'),
        );
      }),
    );
  }
}
