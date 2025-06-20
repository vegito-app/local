import 'package:car2go/vegetable/vegetable_upload/quantity_input_field.dart';
import 'package:flutter/material.dart';

enum SaleType { unit, weight }

enum AvailabilityType { sameDay, futureDate, alreadyHarvested }

class VegetableSaleDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final SaleType saleType;
  final AvailabilityType availabilityType;
  final DateTime? availabilityDate;
  final bool isNewVegetable;

  const VegetableSaleDetailsSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.saleType,
    required this.availabilityType,
    required this.availabilityDate,
    this.isNewVegetable = false, // nouveau paramètre
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: () {
              if (availabilityType == AvailabilityType.sameDay) {
                return Text(
                  'Récolté le jour de la livraison',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                );
              }
              if (availabilityType == AvailabilityType.futureDate &&
                  availabilityDate != null) {
                return Text(
                  'Récolte prévue le ${availabilityDate!.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                );
              }
              if (availabilityType == AvailabilityType.alreadyHarvested &&
                  availabilityDate != null) {
                return Text(
                  'Récolté le ${availabilityDate!.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                );
              }
              return const SizedBox();
            }(),
          ),
          TextFormField(
            key: const Key("nameField"),
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nom'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Obligatoire' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key("descriptionField"),
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          const Text('Quantité mise en vente'),
          QuantityInputField(
            saleType: saleType,
            isNewVegetable: isNewVegetable,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key("priceField"),
            controller: priceController,
            decoration: InputDecoration(
              labelText:
                  saleType == SaleType.unit ? 'Prix (€/unité)' : 'Prix (€/Kg)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}
