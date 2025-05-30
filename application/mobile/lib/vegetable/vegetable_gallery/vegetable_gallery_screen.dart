import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../vegetable_model.dart';
import '../vegetable_provider.dart';

class VegetableGalleryScreen extends StatelessWidget {
  const VegetableGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non authentifié')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes légumes')),
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

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.image)),
                            )
                          : const Center(child: Icon(Icons.image)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(veg.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
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
              );
            },
          );
        },
      ),
    );
  }
}
