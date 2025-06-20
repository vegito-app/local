import 'package:car2go/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vegetable_upload_provider.dart';

class QuantityInputField extends StatefulWidget {
  final SaleType saleType;
  final bool isNewVegetable;

  const QuantityInputField({
    super.key,
    required this.saleType,
    required this.isNewVegetable,
  });

  @override
  State<QuantityInputField> createState() => _QuantityInputFieldState();
}

class _QuantityInputFieldState extends State<QuantityInputField> {
  late final TextEditingController _gramsController = TextEditingController();
  late final TextEditingController _kgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String formatKg(int grams) {
      if (grams < 1000) return (grams / 1000).toStringAsFixed(3);
      if (grams % 1000 == 0) return (grams / 1000).toStringAsFixed(0);
      if (grams % 100 == 0) return (grams / 1000).toStringAsFixed(1);
      if (grams % 10 == 0) return (grams / 1000).toStringAsFixed(2);
      return (grams / 1000).toStringAsFixed(3);
    }

    final provider = context.watch<VegetableUploadProvider>();
    final quantity = provider.quantityAvailable;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gramsController.text = quantity.toString();
        _kgController.text = formatKg(quantity);
      }
    });
    _gramsController.addListener(() {
      if (_gramsController.text.isEmpty) {
        _gramsController.text = '0';
      }
      provider.setQuantityFromGramsString(_gramsController.text);
    });

    if (widget.saleType == SaleType.unit) {
      return TextFormField(
        key: const Key("quantityFieldUnits"),
        controller: _gramsController,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        decoration: const InputDecoration(
          hintText: '0',
          suffixText: 'unité(s)',
        ),
        validator: (val) => val == null || val.isEmpty ? 'Obligatoire' : null,
        onChanged: (val) => provider.setQuantityFromUnitsString(val),
        onTap: () {
          if (_gramsController.text.trim() == '0') {
            _gramsController.clear();
          }
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: const Key("quantityFieldGrams"),
            controller: _gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'g',
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Obligatoire' : null,
            onChanged: (val) => provider.setQuantityFromGramsString(val),
            onTap: () {
              if (_gramsController.text.trim() == '0') {
                _gramsController.clear();
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
            onChanged: (val) => provider.setQuantityFromKgString(val),
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
