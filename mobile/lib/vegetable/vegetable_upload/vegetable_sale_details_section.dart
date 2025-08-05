import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/vegetable/vegetable_upload/quantity_input_field.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

enum SaleType { unit, weight }

enum AvailabilityType { sameDay, futureDate, alreadyHarvested }

class VegetableSaleDetailsSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController availabilityDateController;
  final bool isNewVegetable;

  const VegetableSaleDetailsSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.availabilityDateController,
    required this.quantityController,
    this.isNewVegetable = false,
  });

  @override
  State<VegetableSaleDetailsSection> createState() =>
      _VegetableSaleDetailsSectionState();
}

class _VegetableSaleDetailsSectionState
    extends State<VegetableSaleDetailsSection> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VegetableUploadProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Type de vente",
                      style: Theme.of(context).textTheme.titleMedium),
                  DropdownButton<SaleType>(
                    key: const Key("saleTypeDropdown"),
                    value: provider.saleType,
                    onChanged: (SaleType? newValue) {
                      if (newValue != null) {
                        provider.saleType = newValue;
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                          value: SaleType.unit, child: Text("À l'unité")),
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
                    value: provider.availabilityType,
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
                            firstDate: now.subtract(const Duration(days: 365)),
                            lastDate: now,
                          );
                        }

                        provider.availabilityType = newValue;
                        if (newValue == AvailabilityType.sameDay ||
                            pickedDate == null) {
                          provider.availabilityDate = null;
                          widget.availabilityDateController.clear();
                        } else {
                          provider.availabilityDate = pickedDate;
                          widget.availabilityDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
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
          ]),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: () {
                    if (provider.availabilityType == AvailabilityType.sameDay) {
                      return Text(
                        'Récolté le jour de la livraison',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                      );
                    }
                    if (provider.availabilityType ==
                            AvailabilityType.futureDate &&
                        provider.availabilityDate != null) {
                      return Text(
                        'Récolte prévue le ${provider.availabilityDate!.toLocal().toString().split(' ')[0]}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                      );
                    }
                    if (provider.availabilityType ==
                            AvailabilityType.alreadyHarvested &&
                        provider.availabilityDate != null) {
                      return Text(
                        'Récolté le ${provider.availabilityDate!.toLocal().toString().split(' ')[0]}',
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
                  controller: widget.nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Obligatoire' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key("descriptionField"),
                  controller: widget.descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                const Text('Quantité mise en vente'),
                QuantityInputField(
                  quantityController: widget.quantityController,
                  saleType: provider.saleType,
                  isNewVegetable: widget.isNewVegetable,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key("priceField"),
                  controller: widget.priceController,
                  decoration: InputDecoration(
                    labelText: provider.saleType == SaleType.unit
                        ? 'Prix (€/unité)'
                        : 'Prix (€/Kg)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
