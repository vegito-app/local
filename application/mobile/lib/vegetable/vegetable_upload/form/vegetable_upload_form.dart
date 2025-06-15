// import 'package:car2go/auth/auth_provider.dart';
// import 'package:car2go/vegetable/vegetable_provider.dart';
// import 'package:car2go/vegetable/vegetable_upload/form/vegetable_fields.dart';
// import 'package:car2go/vegetable/vegetable_upload/form/vegetable_photo_picker.dart';
// import 'package:car2go/vegetable/vegetable_upload/vegetable_upload_provider.dart';
// import 'package:car2go/vegetable/vegetable_upload/widget/loading_submit_button.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// enum SaleType { unit, weight }

// class VegetableUploadForm extends StatefulWidget {
//   const VegetableUploadForm({Key? key}) : super(key: key);

//   @override
//   State<VegetableUploadForm> createState() => _VegetableUploadFormState();
// }

// class _VegetableUploadFormState extends State<VegetableUploadForm> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String name = '';
//   String description = '';
//   int? weightGrams;
//   int? priceCents;
//   SaleType saleType = SaleType.unit;

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<VegetableUploadProvider>();

//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             VegetablePhotoPicker(provider: provider),
//             VegetableFields(
//               saleType: saleType,
//               onSaleTypeChanged: (value) => setState(() => saleType = value),
//               onNameSaved: (val) => name = val ?? '',
//               onDescriptionSaved: (val) => description = val ?? '',
//               onWeightSaved: (val) => weightGrams = val,
//               onPriceSaved: (val) => priceCents = val,
//             ),
//             LoadingSubmitButton(
//               isLoading: provider.isLoading,
//               onPressed: () async {
//                 if (!_formKey.currentState!.validate()) return;
//                 _formKey.currentState!.save();
//                 try {
//                   final authProvider = context.read<AuthProvider>();
//                   final vegetableProvider = context.read<VegetableProvider>();
//                   await provider.submitVegetable(
//                     userId: authProvider.user!.uid,
//                     vegetableProvider: vegetableProvider,
//                     name: name,
//                     description: description,
//                     weightGrams: weightGrams ?? 0,
//                     priceCents: priceCents ?? 0,
//                     saleType: saleType == SaleType.unit ? 'unit' : 'weight',
//                   );
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Semantics(
//                           label: 'vegetable-upload-success',
//                           child: const Text('Légume ajouté avec succès'),
//                         ),
//                       ),
//                     );
//                     Navigator.pop(context);
//                   }
//                 } catch (e) {
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Erreur : $e')),
//                     );
//                   }
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
