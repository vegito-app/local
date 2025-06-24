import 'package:flutter/material.dart';
import '../vegetable_model.dart';
import '../vegetable_widgets/vegetable_card_grid.dart';

class BuyerCatalogTab extends StatelessWidget {
  final List<Vegetable> vegetables;

  const BuyerCatalogTab({super.key, required this.vegetables});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        final veg = vegetables[index];
        return VegetableCardGridItem(vegetable: veg);
      },
    );
  }
}
