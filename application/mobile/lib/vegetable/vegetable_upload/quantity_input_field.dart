import 'package:car2go/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
import 'package:flutter/material.dart';

class QuantityInputField extends StatefulWidget {
  final TextEditingController controller;
  final SaleType saleType;
  final bool isNewVegetable;

  const QuantityInputField({
    super.key,
    required this.controller,
    required this.saleType,
    required this.isNewVegetable,
  });

  @override
  State<QuantityInputField> createState() => _QuantityInputFieldState();
}

class _QuantityInputFieldState extends State<QuantityInputField> {
  late final TextEditingController _gramsController = TextEditingController();
  late final TextEditingController _kgController = TextEditingController();
  bool _isSyncing = false;
  int _gramsValue = 0;

  String formatKg(int grams) {
    if (grams < 1000) {
      return (grams / 1000).toStringAsFixed(3); // petit poids, 3 décimales
    }
    if (grams % 1000 == 0) return (grams / 1000).toStringAsFixed(0);
    if (grams % 100 == 0) return (grams / 1000).toStringAsFixed(1);
    if (grams % 10 == 0) return (grams / 1000).toStringAsFixed(2);
    return (grams / 1000).toStringAsFixed(3);
  }

  @override
  void initState() {
    super.initState();
    _gramsValue = int.tryParse(widget.controller.text.trim()) ?? 0;
    _gramsController.text = _gramsValue.toString();
    _kgController.text = formatKg(_gramsValue);

    _gramsController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;

      String raw = _gramsController.text.trim();
      if (raw.isEmpty) {
        widget.controller.text = '0';
        _kgController.text = '0.000';
        _isSyncing = false;
        return;
      }

      // Nettoyage de saisie type "003" => "3"
      final g = int.tryParse(raw) ?? 0;
      _gramsValue = g;
      final cleanGrams = g.toString();
      if (_gramsController.text != cleanGrams) {
        _gramsController.value = TextEditingValue(
          text: cleanGrams,
          selection: TextSelection.collapsed(offset: cleanGrams.length),
        );
      }

      widget.controller.text = g.toString();
      _kgController.text = formatKg(g);
      _isSyncing = false;
    });
    _kgController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;

      String raw = _kgController.text.trim();
      if (raw.isEmpty) {
        widget.controller.text = '0';
        _gramsController.text = '0';
        _isSyncing = false;
        return;
      }

      raw = raw.replaceAll(',', '.');
      final regex = RegExp(r'^(\d*)(\.\d{0,3})?');
      final match = regex.stringMatch(raw) ?? '';
      if (match != raw) {
        _kgController.value = TextEditingValue(
          text: match,
          selection: TextSelection.collapsed(offset: match.length),
        );
        raw = match;
      }

      final doubleKg = double.tryParse(raw) ?? 0.0;
      const maxKg = 1000000.0; // plafond arbitraire

      final safeKg = doubleKg > maxKg ? maxKg : doubleKg;

      final g = (safeKg * 1000).round();
      _gramsValue = g;
      widget.controller.text = g.toString();
      _gramsController.text = g.toString();

      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.saleType == SaleType.unit && !_isSyncing) {
      final current = int.tryParse(widget.controller.text.trim()) ?? 0;
      if (current > 9999 && !widget.isNewVegetable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller.text = '0';
        });
      }
    }
    if (widget.saleType == SaleType.unit) {
      return TextFormField(
        key: const Key("quantityFieldUnits"),
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        decoration: const InputDecoration(
          hintText: '0',
          suffixText: 'unité(s)',
        ),
        validator: (val) => val == null || val.isEmpty ? 'Obligatoire' : null,
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
