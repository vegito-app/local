import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_seller/vegetable_seller_gallery_screen.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_screen.dart';

class VegetableSellerEntryScreen extends StatefulWidget {
  const VegetableSellerEntryScreen({super.key});

  @override
  State<VegetableSellerEntryScreen> createState() =>
      _VegetableSellerEntryScreenState();
}

class _VegetableSellerEntryScreenState
    extends State<VegetableSellerEntryScreen> {
  late Future<void> _reloadFuture;

  @override
  void initState() {
    super.initState();
    final vegetableProvider =
        Provider.of<VegetableListProvider>(context, listen: false);
    _reloadFuture = vegetableProvider.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VegetableListProvider, AuthProvider>(
      builder: (context, vegetableProvider, authProvider, _) {
        final user = authProvider.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Utilisateur non connecté')),
          );
        }

        return FutureBuilder(
          future: _reloadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final myVegetables = vegetableProvider.vegetablesByOwner(user.uid);

            if (myVegetables.isEmpty) {
              return const VegetableUploadScreen();
            } else {
              return const VegetableSellerGalleryScreen();
            }
          },
        );
      },
    );
  }
}
