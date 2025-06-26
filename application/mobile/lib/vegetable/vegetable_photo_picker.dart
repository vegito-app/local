import 'dart:io';

import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';
import 'package:vegito/xfile_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VegetablePhotoPicker extends StatelessWidget {
  final VegetableUploadProvider provider;
  final int maxImages;

  const VegetablePhotoPicker(
      {super.key, required this.provider, this.maxImages = 3});

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
          children: [
            ...provider.images.asMap().entries.take(3).map(
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
                          label: 'set-main-image-${entry.value.imageLabel}',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.star_border),
                            onPressed: () => provider.setMainImage(
                                entry.key,
                                context.read<AuthProvider>().user!.uid,
                                context.read<VegetableListProvider>()),
                            tooltip: "Définir comme principale",
                          ),
                        ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Semantics(
                          label:
                              'delete-image-${entry.value.imageLabel}-${entry.key + 1}',
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
                ),
          ],
        ),
      ],
    );
  }
}
