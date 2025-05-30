import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:flutter/material.dart';

class VegetableImage extends StatelessWidget {
  final Vegetable vegetable;

  const VegetableImage({super.key, required this.vegetable});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = vegetable.imageUrl;

    if (imageUrl.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool isValidated = imageUrl.startsWith('https://cdn.moov.dev/');

    return Stack(
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        if (!isValidated)
          const Positioned(
            bottom: 8,
            right: 8,
            child: Icon(Icons.hourglass_top, color: Colors.orange),
          ),
      ],
    );
  }
}
