import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/info_snackbar.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

class VegetableSubmitButton extends StatelessWidget {
  const VegetableSubmitButton({
    required this.provider,
    super.key,
    required this.formKey,
  });
  final VegetableUploadProvider provider;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'submit-vegetable-button',
      button: true,
      child: Consumer<VegetableUploadProvider>(builder: (context, provider, _) {
        return ElevatedButton(
          key: const Key("submitButton"),
          onPressed: provider.isReadyToSubmit
              ? () async {
                  if (!formKey.currentState!.validate()) return;
                  formKey.currentState!.save();

                  try {
                    final authProvider = context.read<AuthProvider>();
                    final vegetableListProvider =
                        context.read<VegetableListProvider>();
                    await provider.submitVegetable(
                      userId: authProvider.user!.uid,
                      vegetableListProvider: vegetableListProvider,
                    );
                    if (context.mounted) {
                      InfoSnackBar.show(
                        context,
                        'Légume enregistré avec succès',
                        semanticsLabel: 'vegetable-upload-success',
                      );
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      InfoSnackBar.show(
                        context,
                        'Erreur : $e',
                      );
                    }
                  }
                }
              : null,
          child: const Text('Enregistrer'),
        );
      }),
    );
  }
}
