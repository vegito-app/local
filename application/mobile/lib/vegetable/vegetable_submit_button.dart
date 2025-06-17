// ignore_for_file: unused_import

import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_upload_provider.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VegetableSubmitButton extends StatelessWidget {
  const VegetableSubmitButton({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    // required this.weightController,
    required this.quantityController,
    required this.priceController,
    required this.saleType,
    required this.availabilityType,
    required this.availabilityDate,
  });
  final GlobalKey<FormState> formKey;
  final AvailabilityType availabilityType;
  final DateTime? availabilityDate;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  // final TextEditingController weightController;
  final TextEditingController priceController;

  final SaleType saleType;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VegetableUploadProvider>();

    return Semantics(
      label: 'submit-vegetable-button',
      button: true,
      child: ElevatedButton(
        key: const Key("submitButton"),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          formKey.currentState!.save();

          // final weightGrams = int.tryParse(weightController.text) ?? 0;
          final quantity = int.tryParse(quantityController.text) ?? 0;
          final priceCents = int.tryParse(priceController.text) ?? 0;

          try {
            final authProvider = context.read<AuthProvider>();
            final vegetableListProvider = context.read<VegetableListProvider>();
            provider.priceEuros = double.tryParse(priceController.text) ?? 0.0;
            provider.quantityAvailableKg =
                double.tryParse(quantityController.text) ?? 0.0;
            provider.availabilityType = availabilityType;
            provider.availabilityDate = availabilityDate;
            await provider.submitVegetable(
              userId: authProvider.user!.uid,
              vegetableListProvider: vegetableListProvider,
              name: nameController.text,
              description: descriptionController.text,
              // weightGrams: weightGrams,
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
                    child: const Text('Légume ajouté avec succès'),
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
    );
  }
}
