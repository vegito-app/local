import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_provider.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart' show VegetableService;

void main() {
  late VegetableService mockService;
  late VegetableProvider provider;

  setUp(() {
    mockService = VegetableService();
    provider = VegetableProvider(service: mockService);
  });

  test('createVegetable appelle le service et notifie', () async {
    final veg = Vegetable(
      id: '1',
      name: 'Carotte',
      description: 'Orange',
      saleType: 'weight',
      weightGrams: 500,
      priceCents: 150,
      images: [],
      createdAt: DateTime.now(),
      ownerId: 'user1',
    );

    when(mockService.createVegetable(veg)).thenAnswer((_) async => veg);

    bool notified = false;
    provider.addListener(() {
      notified = true;
    });

    final result = await provider.createVegetable(veg);

    expect(result, veg);
    expect(notified, isTrue);
    verify(mockService.createVegetable(veg)).called(1);
  });
}
