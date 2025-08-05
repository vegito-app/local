import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';

import 'vegetable_upload_provider.dart';

class QuantityInputField extends StatefulWidget {
  final SaleType saleType;
  final bool isNewVegetable;
  final TextEditingController quantityController;

  const QuantityInputField({
    super.key,
    required this.saleType,
    required this.isNewVegetable,
    required this.quantityController,
  });

  @override
  State<QuantityInputField> createState() => _QuantityInputFieldState();
}

class _QuantityInputFieldState extends State<QuantityInputField> {
  late final TextEditingController _kgController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    // Synchroniser les changements du controller externe vers le provider
    widget.quantityController.addListener(_onQuantityControllerChanged);
  }

  void _onQuantityControllerChanged() {
    if (!_isUpdating) {
      final provider = context.read<VegetableUploadProvider>();
      if (widget.saleType == SaleType.unit) {
        provider.setQuantityFromUnitsString(widget.quantityController.text);
      } else {
        provider.setQuantityFromGramsString(widget.quantityController.text);
      }
    }
  }

  @override
  void dispose() {
    widget.quantityController.removeListener(_onQuantityControllerChanged);
    _kgController.dispose();
    super.dispose();
  }

  String formatKg(int grams) {
    if (grams < 1000) return (grams / 1000).toStringAsFixed(3);
    if (grams % 1000 == 0) return (grams / 1000).toStringAsFixed(0);
    if (grams % 100 == 0) return (grams / 1000).toStringAsFixed(1);
    if (grams % 10 == 0) return (grams / 1000).toStringAsFixed(2);
    return (grams / 1000).toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VegetableUploadProvider>();
    final quantity = provider.quantityAvailable;

    // Synchroniser le provider vers les controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isUpdating = true;

        final gramsText = quantity.toString();
        final kgText = formatKg(quantity);

        // Mettre à jour le controller externe
        if (widget.quantityController.text != gramsText) {
          widget.quantityController.text = gramsText;
        }

        // Mettre à jour le controller kg
        if (_kgController.text != kgText) {
          _kgController.text = kgText;
        }

        _isUpdating = false;
      }
    });

    if (widget.saleType == SaleType.unit) {
      return TextFormField(
        key: const Key("quantityFieldUnits"),
        controller: widget.quantityController,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        decoration: const InputDecoration(
          hintText: '0',
          suffixText: 'unité(s)',
        ),
        validator: (val) => val == null || val.isEmpty ? 'Obligatoire' : null,
        onTap: () {
          if (widget.quantityController.text.trim() == '0') {
            widget.quantityController.clear();
          }
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: const Key("quantityFieldGrams"),
            controller: widget.quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'g',
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Obligatoire' : null,
            onTap: () {
              if (widget.quantityController.text.trim() == '0') {
                widget.quantityController.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            key: const Key("quantityFieldKg"),
            controller: _kgController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '0.000',
              suffixText: 'Kg',
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Obligatoire' : null,
            onChanged: (val) {
              if (!_isUpdating) {
                final provider = context.read<VegetableUploadProvider>();
                provider.setQuantityFromKgString(val);
              }
            },
            onTap: () {
              if (_kgController.text.trim() == '0.000') {
                _kgController.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}
