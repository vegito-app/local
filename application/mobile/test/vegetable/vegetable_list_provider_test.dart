import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockVegetableService mockService;
  late VegetableListProvider provider;

  setUp(() {
    mockService = MockVegetableService();
    provider = VegetableListProvider(service: mockService);
  });

  test('reload should populate vegetables list', () async {
    final fakeVegetables = [
      Vegetable(
        active: true,
        id: '1',
        name: 'Carotte',
        description: 'Orange',
        saleType: 'weight',
        priceCents: 150,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'user1',
        availabilityType: 'sameDay',
        availabilityDate: null,
        quantityAvailable: 20,
      ),
    ];

    when(mockService.listVegetables()).thenAnswer((_) async => fakeVegetables);

    await provider.reload();

    expect(provider.vegetables.length, 1);
    expect(provider.vegetables.first.name, 'Carotte');
  });

  test('findByIds should return matching vegetables', () async {
    final fakeVegetables = [
      Vegetable(
        active: true,
        id: '1',
        name: 'Tomate',
        description: '',
        saleType: 'unit',
        priceCents: 200,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'user2',
        availabilityType: 'sameDay',
        availabilityDate: null,
        quantityAvailable: 15,
      ),
      Vegetable(
        active: true,
        id: '2',
        name: 'Salade',
        description: '',
        saleType: 'unit',
        priceCents: 100,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'user3',
        availabilityType: 'sameDay',
        availabilityDate: null,
        quantityAvailable: 15,
      ),
    ];

    when(mockService.listVegetables()).thenAnswer((_) async => fakeVegetables);

    final result = await provider.findByIds(['2']);

    expect(result.length, 1);
    expect(result.first.name, 'Salade');
  });
}
