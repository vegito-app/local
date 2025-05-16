// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../providers/account_provider.dart'; // adapte le chemin
// import '../utils/clipboard.dart'; // s'il y a une fonction pour copier
// import '../utils/dialogs.dart'; // s'il y a une boîte de dialogue personnalisée

// class ShowPrivateKeyButton extends ConsumerWidget {
//   const ShowPrivateKeyButton({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final account = ref.watch(accountProvider);

//     if (account == null || !account.hasPrivateKey) {
//       return const SizedBox.shrink(); // Ne rien afficher si pas de clé
//     }

//     return ElevatedButton.icon(
//       icon: const Icon(Icons.lock),
//       label: const Text("Afficher ma privateKey"),
//       onPressed: () async {
//         final confirmed = await showDialog<bool>(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: const Text("Confirmation"),
//                 content: const Text(
//                     "Souhaitez-vous vraiment afficher votre clé privée ? Ne la partagez jamais."),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     child: const Text("Annuler"),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     child: const Text("Afficher"),
//                   ),
//                 ],
//               ),
//             ) ??
//             false;

//         if (!confirmed) return;

//         final privateKey =
//             await ref.read(accountProvider.notifier).getPrivateKey();

//         if (context.mounted) {
//           await showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: const Text("Votre Private Key"),
//               content: SelectableText(privateKey),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     copyToClipboard(privateKey); // fonction utilitaire
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text("Copiée dans le presse-papier")),
//                     );
//                   },
//                   child: const Text("Copier"),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }
