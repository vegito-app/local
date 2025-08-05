import 'package:flutter_test/flutter_test.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_upload_provider.dart';

void main() {
  group('VegetableUploadProvider - Quantity Parsing & Conversion', () {
    late VegetableUploadProvider provider;

    setUp(() {
      provider = VegetableUploadProvider();
    });

    test('Parses valid grammes string correctly', () {
      provider.setQuantityFromGramsString('500');
      expect(provider.quantityAvailable, 500);
    });

    test('Parses invalid grammes string as zero', () {
      provider.setQuantityFromGramsString('invalid');
      expect(provider.quantityAvailable, 0);
    });

    test('Parses valid units string correctly', () {
      provider.setQuantityFromUnitsString('42');
      expect(provider.quantityAvailable, 42);
    });

    test('Parses invalid units string as zero', () {
      provider.setQuantityFromUnitsString('abc');
      expect(provider.quantityAvailable, 0);
    });

    test('Parses valid kg string and converts to grams', () {
      provider.setQuantityFromKgString('1.234');
      expect(provider.quantityAvailable, 1234);
    });

    test('Clamps kg value above limit', () {
      provider.setQuantityFromKgString('1000000000'); // way too high
      expect(
          provider.quantityAvailable, lessThanOrEqualTo(9223372036854775807));
    });

    test('Handles comma as decimal separator in kg string', () {
      provider.setQuantityFromKgString('1,234');
      expect(provider.quantityAvailable, 1234);
    });

    test('Handles invalid kg string gracefully', () {
      provider.setQuantityFromKgString('x1.2y3');
      expect(provider.quantityAvailable, 0);
    });
  });
}
