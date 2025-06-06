import 'package:car2go/config/routes.dart';
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
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un légume',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.vegetableUpload);
            },
          ),
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
              final imageUrl =
                  veg.images.isNotEmpty ? veg.images.first.url : null;

              return Semantics(
                label: 'vegetable-${veg.id}',
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image)),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.hourglass_empty,
                                        color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image en cours de validation',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(veg.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${veg.weightGrams}g - ${veg.priceCents / 100}€'),
                            Text(
                              veg.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
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
