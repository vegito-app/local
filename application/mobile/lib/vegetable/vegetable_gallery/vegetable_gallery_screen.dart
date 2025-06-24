import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_screen.dart';

class VegetableGalleryScreen extends StatelessWidget {
  const VegetableGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vegetableProvider = context.watch<VegetableListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes légumes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un légume',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VegetableUploadScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: vegetableProvider.vegetables.length,
        itemBuilder: (context, index) {
          final vegetable = vegetableProvider.vegetables[index];
          return Semantics(
            label: 'vegetable-${vegetable.id}',
            child: ListTile(
              title: Text(vegetable.name),
              subtitle: Text(vegetable.description),
              // other properties as needed
            ),
          );
        },
      ),
    );
  }
}
