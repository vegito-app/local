import 'package:car2go/config/routes.dart';
import 'package:car2go/vegetable/vegetable_seller/vagatable_seller_gallery_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../vegetable_list_provider.dart';

class VegetableSellerGalleryScreen extends StatelessWidget {
  const VegetableSellerGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non authentifié')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes légumes'),
        actions: [
          Semantics(
            label: 'add-vegetable-button',
            button: true,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(24), // ajuster selon l’icone
                onTap: () async {
                  final result = await Navigator.pushNamed(
                      context, AppRoutes.vegetableUpload);
                  if (result == true && context.mounted) {
                    context.read<VegetableListProvider>().reload();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.add),
                ),
              ),
            ),
          )
        ],
      ),
      body: Consumer<VegetableListProvider>(
        builder: (context, provider, _) {
          final vegetables = provider.vegetablesByOwner(user.uid);

          if (vegetables.isEmpty) {
            return const Center(child: Text('Aucun légume trouvé.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: vegetables.length,
            itemBuilder: (context, index) {
              final veg = vegetables[index];
              final imagePath =
                  veg.images.isNotEmpty ? veg.images.first.publicUrl : null;

              return Semantics(
                label: 'vegetable-${index + 1} ${veg.name}',
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.vegetableUpload,
                      arguments: veg,
                    );
                  },
                  child: VegetableSellerGalleryCard(
                    active: veg.active,
                    imagePath: imagePath,
                    name: veg.name,
                    description: veg.description,
                    saleType: veg.saleType.toString().split('.').last,
                    priceCents: veg.priceCents,
                    quantityAvailable: veg.quantityAvailable,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
