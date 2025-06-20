import 'package:car2go/vegetable/vegetable_upload/quantity_input_field.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_sale_details_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuantityInputField widget tests', () {
    late TextEditingController quantityController;

    setUp(() {
      quantityController = TextEditingController(text: '0');
    });

    testWidgets('initializes controllers with correct values', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: QuantityInputField(
            saleType: SaleType.weight,
            isNewVegetable: true,
          ),
        ),
      ));

      // Check initial text in grammes and kilogrammes
      final gramsField = find.byKey(const Key('quantityFieldGrams'));
      final kgField = find.byKey(const Key('quantityFieldKg'));

      expect(quantityController.text, '0');
      expect(tester.widget<TextFormField>(gramsField).controller!.text, '0');
      expect(tester.widget<TextFormField>(kgField).controller!.text, '0.000');
    });

    testWidgets('syncs grams to kg correctly on input', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: QuantityInputField(
            saleType: SaleType.weight,
            isNewVegetable: true,
          ),
        ),
      ));

      final gramsField = find.byKey(const Key('quantityFieldGrams'));
      final kgField = find.byKey(const Key('quantityFieldKg'));

      await tester.enterText(gramsField, '12345');
      await tester.pumpAndSettle();

      expect(quantityController.text, '12345');
      expect(tester.widget<TextFormField>(kgField).controller!.text,
          '12.345'); // formatted

      await tester.enterText(kgField, '3.500');
      await tester.pumpAndSettle();

      expect(quantityController.text, '3500');
      expect(tester.widget<TextFormField>(gramsField).controller!.text, '3500');
    });

    testWidgets('clears 0 value on tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: QuantityInputField(
            saleType: SaleType.weight,
            isNewVegetable: true,
          ),
        ),
      ));

      final gramsField = find.byKey(const Key('quantityFieldGrams'));
      final kgField = find.byKey(const Key('quantityFieldKg'));

      await tester.tap(gramsField);
      await tester.pump();

      expect(tester.widget<TextFormField>(gramsField).controller!.text, '');

      await tester.tap(kgField);
      await tester.pump();

      expect(tester.widget<TextFormField>(kgField).controller!.text, '');
    });

    testWidgets('limits kg input decimals to 3', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: QuantityInputField(
            saleType: SaleType.weight,
            isNewVegetable: true,
          ),
        ),
      ));

      final kgField = find.byKey(const Key('quantityFieldKg'));

      await tester.enterText(kgField, '1.1234');
      await tester.pumpAndSettle();

      expect(tester.widget<TextFormField>(kgField).controller!.text, '1.123');
    });
  });
}
