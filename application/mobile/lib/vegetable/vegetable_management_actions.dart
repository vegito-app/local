import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

class VegetableManagementActions extends StatelessWidget {
  final VegetableUploadProvider provider;

  const VegetableManagementActions({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.initialVegetable == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: provider.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.isActive ? 'Annonce visible' : 'Annonce masquée',
                  style: TextStyle(
                    color: provider.isActive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  activeColor: Colors.green,
                  value: provider.isActive,
                  onChanged: (value) async {
                    await provider.setVegetableActive(
                      value,
                      context.read<AuthProvider>().user!.uid,
                      context.read<VegetableListProvider>(),
                    );
                    // Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (!provider.isActive)
            const Text(
              'Annonce désactivée provisoirement',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Supprimer'),
            onPressed: () async {
              bool confirmChecked = false;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Confirmation de suppression'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                                'Supprimer définitivement cette annonce ?'),
                            CheckboxListTile(
                              value: confirmChecked,
                              onChanged: (value) =>
                                  setState(() => confirmChecked = value!),
                              title: const Text(
                                  "Je comprends que cette action est irréversible."),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: confirmChecked
                                ? () => Navigator.pop(context, true)
                                : null,
                            child: const Text('Supprimer'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
              if (confirm == true) {
                await Provider.of<VegetableListProvider>(context, listen: false)
                    .deleteVegetable(provider.initialVegetable!.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
