import 'package:flutter/material.dart';

class VegetableImage extends StatelessWidget {
  final String url;

  const VegetableImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool isValidated = url.startsWith('https://cdn.moov.dev/');

    return Stack(
      children: [
        Image.network(
          url,
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
