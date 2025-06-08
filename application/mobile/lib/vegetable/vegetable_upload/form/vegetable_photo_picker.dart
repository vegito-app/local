import 'dart:io';

import 'package:car2go/vegetable/vegetable_upload/vegetable_upload_provider.dart';
import 'package:flutter/material.dart';

class VegetablePhotoPicker extends StatelessWidget {
  final VegetableUploadProvider provider;

  const VegetablePhotoPicker({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photos sélectionnées :"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.images
              .asMap()
              .entries
              .map(
                (entry) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: entry.key == provider.mainImageIndex
                              ? Colors.green
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Semantics(
                        label: 'image_${entry.value.path.split('/').last}',
                        child: entry.value.path.startsWith('http')
                            ? Image.network(entry.value.path, height: 100)
                            : Image.file(File(entry.value.path), height: 100),
                      ),
                    ),
                    if (entry.key != provider.mainImageIndex)
                      Semantics(
                        label: 'set-main-image-${entry.key + 1}',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.star_border),
                          onPressed: () => provider.setMainImage(entry.key),
                          tooltip: "Définir comme principale",
                        ),
                      ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Semantics(
                        label: 'delete-image-${entry.key + 1}',
                        hint: 'Supprimer cette photo',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Supprimer cette photo',
                          onPressed: () => provider.removeImage(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
