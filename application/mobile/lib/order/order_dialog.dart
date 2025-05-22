import 'package:flutter/material.dart';

typedef OnConfirm = void Function(int quantity);

class VegetableOrderDialog extends StatefulWidget {
  final OnConfirm onConfirm;
  const VegetableOrderDialog({super.key, required this.onConfirm});

  @override
  State<VegetableOrderDialog> createState() => _VegetableOrderDialogState();
}

class _VegetableOrderDialogState extends State<VegetableOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Commander'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: '1',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantité'),
          validator: (val) {
            final q = int.tryParse(val ?? '');
            if (q == null || q <= 0) return 'Entrez une quantité valide';
            return null;
          },
          onSaved: (val) => quantity = int.tryParse(val ?? '') ?? 1,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onConfirm(quantity);
              Navigator.pop(context);
            }
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
