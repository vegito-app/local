import 'package:flutter/material.dart';

class VegetableSellerGalleryCard extends StatelessWidget {
  final String? imagePath;
  final String name;
  final String description;
  final String saleType;
  final int priceCents;
  final bool active;
  final int quantityAvailable;

  const VegetableSellerGalleryCard({
    super.key,
    this.imagePath,
    required this.name,
    required this.description,
    required this.saleType,
    required this.priceCents,
    required this.active,
    required this.quantityAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1.0 : 0.5,
      child: Semantics(
        label: 'vegetable-card',
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: imagePath != null && imagePath!.isNotEmpty
                    ? Image.network(
                        imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Image en cours de validation',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12),
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
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      saleType == 'weight'
                          ? '${priceCents / 100}€ / Kg'
                          : '${priceCents / 100}€ / unité',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      saleType == 'weight'
                          ? (quantityAvailable < 1000
                              ? 'Reste : ${quantityAvailable} g'
                              : 'Reste : ${(quantityAvailable / 1000).toStringAsFixed((quantityAvailable % 1000 == 0) ? 0 : ((quantityAvailable % 100 == 0) ? 1 : ((quantityAvailable % 10 == 0) ? 2 : 3)))} Kg')
                          : 'Reste : ${quantityAvailable.toInt()} pièces',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (!active)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Hors ligne',
                          style: TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
