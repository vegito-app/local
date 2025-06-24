import 'package:flutter/material.dart';
import 'package:vegito/vegetable/vegetable_upload/quantity_input_field.dart';

enum SaleType { unit, weight }

enum AvailabilityType { sameDay, futureDate, alreadyHarvested }

class VegetableSaleDetailsSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final SaleType initialSaleType;
  final AvailabilityType initialAvailabilityType;
  final DateTime? initialAvailabilityDate;
  final TextEditingController availabilityDateController;
  final bool isNewVegetable;
  final void Function(SaleType) onSaleTypeChanged;
  final void Function(AvailabilityType, DateTime?) onAvailabilityChanged;

  const VegetableSaleDetailsSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.initialSaleType,
    required this.initialAvailabilityType,
    required this.initialAvailabilityDate,
    required this.availabilityDateController,
    required this.onSaleTypeChanged,
    required this.onAvailabilityChanged,
    this.isNewVegetable = false,
  });

  @override
  State<VegetableSaleDetailsSection> createState() =>
      _VegetableSaleDetailsSectionState();
}

class _VegetableSaleDetailsSectionState
    extends State<VegetableSaleDetailsSection> {
  late SaleType saleType;
  late AvailabilityType availabilityType;
  DateTime? availabilityDate;

  @override
  void initState() {
    super.initState();
    saleType = widget.initialSaleType;
    availabilityType = widget.initialAvailabilityType;
    availabilityDate = widget.initialAvailabilityDate;
  }

  @override
  Widget build(BuildContext context) {
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
                    value: saleType,
                    onChanged: (SaleType? newValue) {
                      if (newValue != null) {
                        setState(() {
                          saleType = newValue;
                        });
                        widget.onSaleTypeChanged(newValue);
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
                            firstDate: now.subtract(const Duration(days: 365)),
                            lastDate: now,
                          );
                        }

                        setState(() {
                          availabilityType = newValue;
                          if (newValue == AvailabilityType.sameDay ||
                              pickedDate == null) {
                            availabilityDate = null;
                            widget.availabilityDateController.clear();
                          } else {
                            availabilityDate = pickedDate;
                            widget.availabilityDateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          }
                        });

                        widget.onAvailabilityChanged(newValue, pickedDate);
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
                  saleType: saleType,
                  isNewVegetable: widget.isNewVegetable,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key("priceField"),
                  controller: widget.priceController,
                  decoration: InputDecoration(
                    labelText: saleType == SaleType.unit
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
