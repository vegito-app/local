// import 'package:car2go/vegetable/vegetable_upload/form/vegetable_upload_form.dart';
// import 'package:flutter/material.dart';

// class VegetableFields extends StatelessWidget {
//   final SaleType saleType;
//   final ValueChanged<SaleType> onSaleTypeChanged;
//   final FormFieldSetter<String> onNameSaved;
//   final FormFieldSetter<String> onDescriptionSaved;
//   final FormFieldSetter<int?> onWeightSaved;
//   final FormFieldSetter<int?> onPriceSaved;

//   const VegetableFields({
//     super.key,
//     required this.saleType,
//     required this.onSaleTypeChanged,
//     required this.onNameSaved,
//     required this.onDescriptionSaved,
//     required this.onWeightSaved,
//     required this.onPriceSaved,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         Text("Détails du légume",
//             style: Theme.of(context).textTheme.titleLarge),
//         const SizedBox(height: 12),
//         Text("Type de vente", style: Theme.of(context).textTheme.titleMedium),
//         Semantics(
//           label: 'dropdown-sale-type',
//           child: DropdownButton<SaleType>(
//             key: const Key("saleTypeDropdown"),
//             value: saleType,
//             onChanged: (SaleType? newValue) {
//               if (newValue != null) {
//                 onSaleTypeChanged(newValue);
//               }
//             },
//             items: const [
//               DropdownMenuItem(value: SaleType.unit, child: Text("À l’unité")),
//               DropdownMenuItem(
//                   value: SaleType.weight, child: Text("Au poids (€/kg)")),
//             ],
//           ),
//         ),
//         // DropdownButtonFormField<SaleType>(
//         //   value: saleType,
//         //   decoration: const InputDecoration(labelText: 'Type de vente'),
//         //   items: const [
//         //     DropdownMenuItem(
//         //       value: SaleType.unit,
//         //       child: Text('À l’unité'),
//         //     ),
//         //     DropdownMenuItem(
//         //       value: SaleType.weight,
//         //       child: Text('Au poids'),
//         //     ),
//         //   ],
//         //   onChanged: (saleType) {
//         //     if (saleType != null) {
//         //       onSaleTypeChanged(saleType);
//         //     }
//         //   },
//         // ),
//         TextFormField(
//           decoration: const InputDecoration(labelText: 'Nom du légume'),
//           validator: (val) =>
//               val == null || val.isEmpty ? 'Champ requis' : null,
//           onSaved: onNameSaved,
//         ),
//         TextFormField(
//           decoration: const InputDecoration(labelText: 'Description'),
//           maxLines: 2,
//           onSaved: onDescriptionSaved,
//         ),
//         if (saleType == SaleType.weight)
//           TextFormField(
//             decoration: const InputDecoration(labelText: 'Poids en grammes'),
//             keyboardType: TextInputType.number,
//             validator: (val) {
//               if (saleType == SaleType.weight && (val == null || val.isEmpty)) {
//                 return 'Champ requis';
//               }
//               return null;
//             },
//             onSaved: (val) => onWeightSaved(int.tryParse(val ?? '')),
//           ),
//         TextFormField(
//           decoration: const InputDecoration(labelText: 'Prix en centimes'),
//           keyboardType: TextInputType.number,
//           validator: (val) =>
//               val == null || val.isEmpty ? 'Champ requis' : null,
//           onSaved: (val) => onPriceSaved(int.tryParse(val ?? '')),
//         ),
//       ],
//     );
//   }
// }
